defmodule DianWeb.UserRegistrationController do
  use DianWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Dian.Accounts
  alias DianWeb.JSend
  alias DianWeb.Schemas.{JSendSuccess, JSendValidationFail, UserRegistrationRequest}

  action_fallback DianWeb.FallbackController

  tags ["users"]

  operation :create,
    operation_id: "register_user",
    summary: "Register user",
    description:
      "Creates an unconfirmed account for a QQ email address and sends a magic login link.",
    request_body:
      {"User registration params", "application/json", UserRegistrationRequest, required: true},
    responses: [
      ok: {"Registration accepted", "application/json", JSendSuccess},
      unprocessable_entity: {"Validation errors", "application/json", JSendValidationFail}
    ]

  def create(conn, %{"user" => user_params}) do
    with {:ok, user} <- Accounts.register_user(user_params),
         {:ok, _} <-
           Accounts.deliver_login_instructions(user, &url(~p"/redirects/users/login/#{&1}")) do
      conn
      |> JSend.success_json()
    end
  end
end
