defmodule DianBot.GroupMember do
  @type role :: String.t()
  @type sex :: String.t()

  @type t :: %__MODULE__{
          group_id: integer(),
          user_id: integer(),
          nickname: String.t(),
          display_name: String.t(),
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
    # extract from "card"
    :display_name,
    :join_time,
    :last_sent_time,
    :is_robot,
    :role,
    :title
  ]

  @spec build(map()) :: t()
  def build(data) when is_map(data) do
    %__MODULE__{
      user_id: data["user_id"],
      group_id: data["group_id"],
      nickname: data["nickname"],
      display_name: data["card"],
      join_time: data["join_time"],
      last_sent_time: data["last_sent_time"],
      is_robot: data["is_robot"],
      role: data["role"],
      title: data["title"]
    }
  end
end
