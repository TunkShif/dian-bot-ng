defmodule DianWeb.GroupJSON do
  alias DianBot.Group
  alias Dian.Steam.SteamPlayer

  def one(%Group{} = group) do
    base(group)
  end

  def one(%{group: group, members: members}) do
    base(group) |> Map.put(:members, Enum.map(members, &member/1))
  end

  def many(groups), do: Enum.map(groups, &one/1)

  defp base(%Group{} = group) do
    %{
      group_id: group.group_id,
      group_name: group.group_name,
      group_remark: group.group_remark,
      avatar_url: group.avatar_url,
      member_count: group.member_count,
      enabled: group.enabled,
      steam_status_enabled: group.steam_status_enabled,
      steam_achievements_enabled: group.steam_achievements_enabled,
      daily_steam_summary_enabled: group.daily_steam_summary_enabled,
      is_admin: group.is_admin
    }
  end

  def member(member) when is_map(member) do
    %{
      user_id: Map.get(member, :user_id),
      group_id: Map.get(member, :group_id),
      nickname: Map.get(member, :nickname),
      display_name: Map.get(member, :display_name),
      avatar_url: Map.get(member, :avatar_url),
      join_time: Map.get(member, :join_time),
      last_sent_time: Map.get(member, :last_sent_time),
      is_robot: Map.get(member, :is_robot),
      role: Map.get(member, :role),
      title: Map.get(member, :title),
      steam_player: steam_player_summary(Map.get(member, :steam_player))
    }
  end

  defp steam_player_summary(nil), do: nil

  defp steam_player_summary(%SteamPlayer{} = steam_player) do
    %{
      steam_id: steam_player.steam_id,
      display_name: steam_player.display_name
    }
  end
end
