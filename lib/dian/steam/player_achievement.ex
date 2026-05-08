defmodule Dian.Steam.PlayerAchievement do
  defstruct [
    :api_name,
    :achieved?,
    :unlocktime,
    :display_name,
    :description
  ]

  @type t :: %__MODULE__{
          api_name: String.t() | nil,
          achieved?: boolean(),
          unlocktime: integer() | nil,
          display_name: String.t() | nil,
          description: String.t() | nil
        }

  def build(params) do
    %__MODULE__{
      api_name: params["apiname"],
      achieved?: params["achieved"] == 1,
      unlocktime: params["unlocktime"],
      display_name: params["name"],
      description: params["description"]
    }
  end
end
