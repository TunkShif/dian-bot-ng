defmodule DianWeb.GroupJSON do
  alias DianBot.Group
  alias DianBot.GroupMember

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

  def member(%GroupMember{} = member) do
    %{
      user_id: member.user_id,
      group_id: member.group_id,
      nickname: member.nickname,
      display_name: member.display_name,
      avatar_url: member.avatar_url,
      join_time: member.join_time,
      last_sent_time: member.last_sent_time,
      is_robot: member.is_robot,
      role: member.role,
      title: member.title
    }
  end
end
