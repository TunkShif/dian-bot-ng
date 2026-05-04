defmodule DianWeb.UserSettingsController do
  use DianWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Dian.Accounts
  alias DianWeb.JSend
  alias DianWeb.Schemas
  alias DianWeb.UserAuth

  action_fallback DianWeb.FallbackController

  tags ["users"]

  operation :update,
    operation_id: "update_user_settings",
    summary: "Update user settings",
    description:
      "Updates settings for the authenticated user. Currently supports password changes.",
    request_body:
      {"User settings params", "application/json", Schemas.UserSettingsUpdateRequest,
       required: true},
    responses: [
      ok: {"Settings updated", "application/json", Schemas.JSendSuccess},
      unauthorized: {"Authentication required", "application/json", Schemas.JSendMessageFail},
      unprocessable_entity: {"Validation errors", "application/json", Schemas.JSendValidationFail}
    ]

  def update(conn, %{"user" => user_params}) do
    with {:ok, {user, _expired_tokens}} <-
           Accounts.update_user_password(conn.assigns.current_scope, user_params) do
      conn
      |> UserAuth.create_user_session(user, %{})
      |> JSend.success_json()
    end
  end
end
