defmodule DianBot.Group do
  alias Dian.Accounts

  @type t :: %__MODULE__{
          group_remark: String.t(),
          group_id: integer(),
          group_name: String.t(),
          member_count: integer(),
          avatar_url: String.t(),
          enabled: boolean(),
          is_admin: boolean(),
          steam_status_enabled: boolean(),
          steam_achievements_enabled: boolean(),
          daily_steam_summary_enabled: boolean()
        }

  defstruct [
    :group_id,
    :group_name,
    :group_remark,
    :member_count,
    :avatar_url,
    enabled: false,
    steam_status_enabled: false,
    steam_achievements_enabled: false,
    daily_steam_summary_enabled: false,
    is_admin: false
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
