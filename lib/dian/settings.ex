defmodule Dian.Settings do
  alias Dian.Repo
  alias Dian.Settings.GlobalSetting
  alias Dian.Settings.GroupSetting

  import Ecto.Query

  def can_user_register?(qq_id) do
    case get_superadmin_user_id() do
      nil -> true
      _ -> user_in_enabled_groups?(qq_id)
    end
  end

  def superadmin_user?(user_id) when is_integer(user_id) do
    get_superadmin_user_id() == user_id
  end

  def superadmin_user?(_user_id), do: false

  def get_group_setting(group_id) do
    Repo.get_by(GroupSetting, group_id: to_string(group_id))
  end

  def group_enabled?(group_id) do
    case get_group_setting(group_id) do
      %GroupSetting{enabled: enabled} -> enabled
      nil -> false
    end
  end

  def update_group_setting(group_id, attrs) when is_map(attrs) do
    group_id = to_string(group_id)
    attrs = Map.put(attrs, "group_id", group_id)

    (get_group_setting(group_id) || %GroupSetting{})
    |> GroupSetting.changeset(attrs)
    |> Repo.insert_or_update()
  end

  def maybe_set_superadmin(repo \\ Repo, user_id) do
    case repo.get(GlobalSetting, 1) do
      nil ->
        %GlobalSetting{id: 1}
        |> GlobalSetting.superadmin_changeset(%{superadmin_user_id: user_id})
        |> repo.insert(on_conflict: :nothing)

      %GlobalSetting{superadmin_user_id: nil} = settings ->
        settings
        |> GlobalSetting.superadmin_changeset(%{superadmin_user_id: user_id})
        |> repo.update()

      %GlobalSetting{} = settings ->
        {:ok, settings}
    end
  end

  defp get_superadmin_user_id() do
    case Repo.get(GlobalSetting, 1) do
      nil -> nil
      settings -> settings.superadmin_user_id
    end
  end

  defp user_in_enabled_groups?(qq_id) do
    group_ids = Repo.all(from g in GroupSetting, where: g.enabled == true, select: g.group_id)

    DianBot.find_group_member_in_groups(group_ids, qq_id) != nil
  end
end
