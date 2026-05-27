defmodule DianWeb.SteamPlayerController do
  use DianWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Dian.Steam
  alias DianWeb.JSend
  alias DianWeb.Schemas
  alias DianWeb.SteamPlayerJSON

  action_fallback DianWeb.FallbackController

  tags ["steam"]

  operation :show_by_steam_id,
    operation_id: "show_steam_player_by_steam_id",
    summary: "Show Steam player summary by Steam ID",
    description: "Returns the Steam player summary for a given Steam ID.",
    parameters: [
      steam_id: [
        in: :path,
        type: :string,
        description: "17-digit Steam ID",
        example: "76561198012345678"
      ]
    ],
    responses: [
      ok: {"Steam player summary", "application/json", Schemas.SteamPlayerSummaryResponse},
      not_found: {"Steam player not found", "application/json", Schemas.JSendMessageFail},
      bad_gateway: {"Steam API unavailable", "application/json", Schemas.JSendMessageFail},
      unauthorized: {"Authentication required", "application/json", Schemas.JSendMessageFail}
    ]

  operation :show_by_qq_id,
    operation_id: "show_steam_player_by_qq_id",
    summary: "Show Steam player summary by QQ ID",
    description:
      "Returns the Steam player summary for a QQ ID. When no Steam account is bound, the response succeeds with a null player.",
    parameters: [
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
      bad_gateway: {"Steam API unavailable", "application/json", Schemas.JSendMessageFail},
      unauthorized: {"Authentication required", "application/json", Schemas.JSendMessageFail}
    ]

  operation :bind_self,
    operation_id: "bind_steam_player_self",
    summary: "Bind Steam account to current user",
    description:
      "Binds the current user to a Steam ID. Replaces any existing binding for the same user or Steam ID.",
    request_body:
      {"Steam bind params", "application/json", Schemas.SteamPlayerBindRequest, required: true},
    responses: [
      ok: {"Steam binding created", "application/json", Schemas.SteamPlayerBindingResponse},
      unauthorized: {"Authentication required", "application/json", Schemas.JSendMessageFail},
      unprocessable_entity: {"Validation errors", "application/json", Schemas.JSendValidationFail}
    ]

  operation :bind_member,
    operation_id: "bind_steam_player_member",
    summary: "Bind Steam account to a group member",
    description:
      "Binds a group member to a Steam ID. Requires group admin privileges. Replaces any existing binding for the same QQ ID or Steam ID.",
    parameters: [
      group_id: [
        in: :path,
        type: :string,
        description: "DianBot group ID",
        example: "100"
      ],
      qq_id: [
        in: :path,
        type: :string,
        description: "QQ ID of the group member to bind",
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

  operation :unbind_self,
    operation_id: "unbind_steam_player_self",
    summary: "Unbind Steam account from current user",
    description:
      "Removes the Steam binding for the authenticated user. Returns success even if no binding exists.",
    responses: [
      ok: {"Steam binding removed", "application/json", Schemas.JSendSuccess},
      unauthorized: {"Authentication required", "application/json", Schemas.JSendMessageFail}
    ]

  def show_by_steam_id(conn, %{"steam_id" => steam_id}) do
    case Steam.get_player_summaries([steam_id]) do
      {:ok, [summary]} ->
        JSend.success_json(conn, %{player: SteamPlayerJSON.summary(summary)})

      {:ok, []} ->
        {:error, :not_found}

      {:error, _reason} ->
        {:error, :steam_api_error}
    end
  end

  def show_by_qq_id(conn, %{"qq_id" => qq_id}) do
    with {:ok, summary} <- Steam.get_bound_player_summary_by_qq_id(qq_id) do
      player = if summary, do: SteamPlayerJSON.summary(summary), else: nil
      JSend.success_json(conn, %{player: player})
    end
  end

  def bind_self(conn, %{"steam_id" => steam_id} = params) do
    with {:ok, steam_player} <-
           Steam.bind_self(conn.assigns.current_scope, steam_id, Map.get(params, "display_name")) do
      JSend.success_json(conn, %{binding: SteamPlayerJSON.binding(steam_player)})
    end
  end

  def bind_member(
        conn,
        %{"group_id" => group_id, "qq_id" => qq_id, "steam_id" => steam_id} = params
      ) do
    with {:ok, steam_player} <-
           Steam.bind_member(
             conn.assigns.current_scope,
             group_id,
             qq_id,
             steam_id,
             Map.get(params, "display_name")
           ) do
      JSend.success_json(conn, %{binding: SteamPlayerJSON.binding(steam_player)})
    end
  end

  def unbind_self(conn, _params) do
    case Steam.unbind_self(conn.assigns.current_scope) do
      :ok ->
        JSend.success_json(conn, %{unbound: true})

      {:error, :not_found} ->
        JSend.success_json(conn, %{unbound: false})

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
