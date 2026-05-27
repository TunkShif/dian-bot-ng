defmodule DianBot.GroupMember do
  alias Dian.Accounts

  @type role :: :owner | :admin | :member
  @type sex :: String.t()

  @type t :: %__MODULE__{
          group_id: integer(),
          user_id: integer(),
          nickname: String.t(),
          display_name: String.t(),
          avatar_url: String.t(),
          join_time: integer(),
          last_sent_time: integer(),
          is_robot: boolean(),
          role: role(),
          title: String.t()
        }

  defstruct [
    :user_id,
    :group_id,
    :nickname,
    :display_name,
    :avatar_url,
    :join_time,
    :last_sent_time,
    :is_robot,
    :role,
    :title
  ]

  @spec build(map()) :: t()
  def build(data) when is_map(data) do
    user_id = data["user_id"]

    %__MODULE__{
      user_id: user_id,
      group_id: data["group_id"],
      nickname: data["nickname"],
      display_name: data["card"],
      avatar_url: Accounts.build_user_avatar_url(user_id),
      join_time: data["join_time"],
      last_sent_time: data["last_sent_time"],
      is_robot: data["is_robot"],
      role: normalize_role(data["role"]),
      title: data["title"]
    }
  end

  def admin?(%__MODULE__{} = member) do
    member.role in [:owner, :admin]
  end

  defp normalize_role("owner"), do: :owner
  defp normalize_role("admin"), do: :admin
  defp normalize_role(_), do: :member
end
