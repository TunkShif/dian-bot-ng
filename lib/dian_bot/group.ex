defmodule DianBot.Group do
  @type t :: %__MODULE__{
          group_remark: String.t(),
          group_id: integer(),
          group_name: String.t(),
          member_count: integer()
        }

  defstruct [
    :group_id,
    :group_name,
    :group_remark,
    :member_count
  ]

  @spec build(map()) :: t()
  def build(data) when is_map(data) do
    %__MODULE__{
      group_id: data["group_id"],
      group_name: data["group_name"],
      group_remark: data["group_remark"],
      member_count: data["member_count"]
    }
  end
end
