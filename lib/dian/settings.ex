defmodule Dian.Settings do
  alias Dian.Repo
  alias Dian.Settings.GlobalSetting

  def can_user_register?(qq_id) do
    case get_superadmin_user_id() do
      nil -> true
      _ -> user_in_enabled_groups?(qq_id)
    end
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

  defp user_in_enabled_groups?(_qq_id) do
    # TODO: to be implemented
    true
  end
end
