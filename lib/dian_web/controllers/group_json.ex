defmodule DianWeb.GroupJSON do
  alias DianBot.Group
  alias Dian.Steam.SteamPlayer

  def one(%Group{} = group) do
    %{
      group_id: group.group_id,
      group_name: group.group_name,
      group_remark: group.group_remark,
      avatar_url: group.avatar_url,
      member_count: group.member_count,
      enabled: Map.get(group, :enabled, false),
      is_admin: Map.get(group, :is_admin, false)
    }
  end

  def many(groups), do: Enum.map(groups, &one/1)

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
