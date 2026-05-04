defmodule DianBot.Group do
  alias Dian.Accounts

  @type t :: %__MODULE__{
          group_remark: String.t(),
          group_id: integer(),
          group_name: String.t(),
          member_count: integer(),
          avatar_url: String.t()
        }

  defstruct [
    :group_id,
    :group_name,
    :group_remark,
    :member_count,
    :avatar_url
  ]

  @spec build(map()) :: t()
  def build(data) when is_map(data) do
    group_id = data["group_id"]

    %__MODULE__{
      group_id: group_id,
      group_name: data["group_name"],
      group_remark: data["group_remark"],
      member_count: data["member_count"],
      avatar_url: Accounts.build_group_avatar_url(group_id)
    }
  end
end
