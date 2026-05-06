defmodule Dian.Groups do
  alias Dian.Accounts.Scope
  alias Dian.Accounts.User
  alias Dian.Settings
  alias DianBot.GroupMember

  def list_groups(%Scope{user: %User{} = user, qq_id: qq_id}) when is_binary(qq_id) do
    with {:ok, groups} <- DianBot.get_group_list() do
      groups =
        if Settings.superadmin_user?(user.id) do
          Enum.map(groups, &enrich_group(&1, true))
        else
          groups
          |> Enum.map(&enrich_group_for_member(&1, qq_id))
          |> Enum.reject(&is_nil/1)
        end

      {:ok, groups}
    end
  end

  def get_group(%Scope{user: %User{} = user, qq_id: qq_id}, group_id) when is_binary(qq_id) do
    superadmin? = Settings.superadmin_user?(user.id)

    with {:ok, member} <- get_current_member(group_id, qq_id, superadmin?),
         :ok <- authorize_group_access(member, superadmin?),
         {:ok, group} <- DianBot.get_group_info(group_id),
         {:ok, members} <- DianBot.get_group_member_list(group_id) do
      group =
        group
        |> enrich_group(group_admin?(member, superadmin?))
        |> Map.put(:members, members)

      {:ok, group}
    end
  end

  def update_group(scope, group_id, attrs) when is_map(attrs) do
    with :ok <- authorize_group_admin(scope, group_id) do
      Settings.update_group_setting(group_id, Map.take(attrs, ["enabled"]))
    end
  end

  @doc """
  Authorizes that the current scope's user is a group admin for the given group.

  Returns `:ok` if the user is a superadmin or a group admin, `{:error, :forbidden}` otherwise.
  """
  def authorize_group_admin(%Scope{user: %User{} = user, qq_id: qq_id}, group_id)
      when is_binary(qq_id) do
    superadmin? = Settings.superadmin_user?(user.id)

    with {:ok, member} <- get_current_member(group_id, qq_id, superadmin?, no_cache: true) do
      verify_admin_member(member, superadmin?)
    end
  end

  defp enrich_group_for_member(group, qq_id) do
    case DianBot.get_group_member_info(group.group_id, qq_id) do
      {:ok, member} -> enrich_group(group, GroupMember.admin?(member))
      {:error, _reason} -> nil
    end
  end

  defp enrich_group(group, admin?) do
    group
    |> Map.put(:enabled, Settings.group_enabled?(group.group_id))
    |> Map.put(:is_admin, admin?)
  end

  defp get_current_member(group_id, qq_id, superadmin?, opts \\ [])
  defp get_current_member(_group_id, _qq_id, true, _opts), do: {:ok, nil}

  defp get_current_member(group_id, qq_id, false, opts) do
    DianBot.get_group_member_info(group_id, qq_id, opts)
  end

  defp authorize_group_access(_member, true), do: :ok
  defp authorize_group_access(%GroupMember{}, false), do: :ok
  defp authorize_group_access(_member, false), do: {:error, :forbidden}

  defp verify_admin_member(_member, true), do: :ok

  defp verify_admin_member(%GroupMember{} = member, false) do
    if GroupMember.admin?(member), do: :ok, else: {:error, :forbidden}
  end

  defp verify_admin_member(_member, false), do: {:error, :forbidden}

  defp group_admin?(_member, true), do: true
  defp group_admin?(%GroupMember{} = member, false), do: GroupMember.admin?(member)
  defp group_admin?(_member, false), do: false
end
