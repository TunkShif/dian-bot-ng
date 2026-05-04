defmodule DianWeb.GroupController do
  use DianWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Dian.Groups
  alias DianWeb.JSend
  alias DianWeb.Schemas

  action_fallback DianWeb.FallbackController

  tags ["groups"]

  operation :index,
    operation_id: "list_groups",
    summary: "List groups",
    description: "Returns DianBot groups visible to the authenticated user.",
    responses: [
      ok: {"Visible groups", "application/json", Schemas.GroupListResponse},
      unauthorized: {"Authentication required", "application/json", Schemas.JSendMessageFail}
    ]

  operation :show,
    operation_id: "show_group",
    summary: "Show group",
    description: "Returns one visible DianBot group with its members.",
    parameters: [
      id: [in: :path, type: :string, description: "DianBot group ID", example: "100"]
    ],
    responses: [
      ok: {"Group details", "application/json", Schemas.GroupResponse},
      not_found: {"Group not found", "application/json", Schemas.JSendMessageFail},
      unauthorized: {"Authentication required", "application/json", Schemas.JSendMessageFail}
    ]

  operation :update,
    operation_id: "update_group",
    summary: "Update group settings",
    description: "Updates settings for one DianBot group when the user can administer it.",
    parameters: [
      id: [in: :path, type: :string, description: "DianBot group ID", example: "100"]
    ],
    request_body:
      {"Group settings params", "application/json", Schemas.GroupUpdateRequest, required: true},
    responses: [
      ok: {"Updated group settings", "application/json", Schemas.GroupSettingsResponse},
      forbidden: {"Group administration required", "application/json", Schemas.JSendMessageFail},
      unauthorized: {"Authentication required", "application/json", Schemas.JSendMessageFail},
      unprocessable_entity: {"Validation errors", "application/json", Schemas.JSendValidationFail}
    ]

  def index(conn, _params) do
    with {:ok, groups} <- Groups.list_groups(conn.assigns.current_scope) do
      JSend.success_json(conn, %{groups: groups})
    end
  end

  def show(conn, %{"id" => group_id}) do
    with {:ok, group} <- Groups.get_group(conn.assigns.current_scope, group_id) do
      JSend.success_json(conn, %{group: group})
    end
  end

  def update(conn, %{"id" => group_id} = params) do
    with {:ok, group_setting} <- Groups.update_group(conn.assigns.current_scope, group_id, params) do
      JSend.success_json(conn, %{
        group: %{id: group_setting.group_id, enabled: group_setting.enabled}
      })
    end
  end
end
