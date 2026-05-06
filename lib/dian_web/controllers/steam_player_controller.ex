defmodule DianWeb.SteamPlayerController do
  use DianWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Dian.Steam
  alias DianWeb.JSend
  alias DianWeb.Schemas
  alias DianWeb.SteamPlayerJSON

  action_fallback DianWeb.FallbackController

  tags ["steam"]

  operation :show,
    operation_id: "show_steam_player",
    summary: "Show Steam player summary",
    description: "Returns the Steam player summary for a given steam_id or QQ ID.",
    parameters: [
      steam_id: [
        in: :path,
        type: :string,
        description: "17-digit Steam ID",
        example: "76561198012345678"
      ],
      qq_id: [
        in: :path,
        type: :string,
        description: "QQ ID with a bound Steam account",
        example: "123456789"
      ]
    ],
    responses: [
      ok: {"Steam player summary", "application/json", Schemas.SteamPlayerSummaryResponse},
      not_found: {"Steam player not found", "application/json", Schemas.JSendMessageFail},
      unauthorized: {"Authentication required", "application/json", Schemas.JSendMessageFail}
    ]

  operation :update,
    operation_id: "update_steam_player",
    summary: "Bind a Steam account",
    description:
      "Binds a QQ ID to a Steam ID. Replaces any existing binding for the same QQ ID or Steam ID.",
    parameters: [
      group_id: [
        in: :path,
        type: :string,
        description: "DianBot group ID (admin bind only)",
        example: "100"
      ],
      qq_id: [
        in: :path,
        type: :string,
        description: "QQ ID of the group member to bind (admin bind only)",
        example: "123456789"
      ]
    ],
    request_body:
      {"Steam bind params", "application/json", Schemas.SteamPlayerBindRequest, required: true},
    responses: [
      ok: {"Steam binding created", "application/json", Schemas.SteamPlayerBindingResponse},
      forbidden: {"Group administration required", "application/json", Schemas.JSendMessageFail},
      unauthorized: {"Authentication required", "application/json", Schemas.JSendMessageFail},
      unprocessable_entity: {"Validation errors", "application/json", Schemas.JSendValidationFail}
    ]

  def show(conn, %{"qq_id" => qq_id}) do
    with {:ok, summary} <- Steam.get_bound_player_summary_by_qq_id(qq_id) do
      JSend.success_json(conn, %{player: SteamPlayerJSON.summary(summary)})
    end
  end

  def show(conn, %{"steam_id" => steam_id}) do
    case Steam.get_player_summary(steam_id) do
      nil -> {:error, :not_found}
      summary -> JSend.success_json(conn, %{player: SteamPlayerJSON.summary(summary)})
    end
  end

  def update(conn, %{"group_id" => group_id, "qq_id" => qq_id, "steam_id" => steam_id}) do
    with {:ok, steam_player} <-
           Steam.bind_member(conn.assigns.current_scope, group_id, qq_id, steam_id) do
      JSend.success_json(conn, %{binding: SteamPlayerJSON.binding(steam_player)})
    end
  end

  def update(conn, %{"steam_id" => steam_id}) do
    with {:ok, steam_player} <- Steam.bind_self(conn.assigns.current_scope, steam_id) do
      JSend.success_json(conn, %{binding: SteamPlayerJSON.binding(steam_player)})
    end
  end
end
