defmodule DianWeb.UserSessionController do
  use DianWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Dian.Accounts
  alias DianWeb.JSend
  alias DianWeb.Schemas
  alias DianWeb.UserAuth

  action_fallback DianWeb.FallbackController

  tags ["users"]

  operation :create,
    operation_id: "login_user",
    summary: "Log in user",
    description:
      "Requests a magic login link when only email is provided, or starts a password session when password is provided.",
    request_body:
      {"User login params", "application/json", Schemas.UserSessionCreateRequest, required: true},
    responses: [
      ok: {"Login succeeded or magic link accepted", "application/json", Schemas.JSendSuccess},
      unauthorized:
        {"Invalid password credentials", "application/json", Schemas.JSendMessageFail},
      not_found: {"Email not found for magic link", "application/json", Schemas.JSendMessageFail}
    ]

  operation :show,
    operation_id: "get_current_user",
    summary: "Show current user",
    description:
      "Returns the current session user when authenticated, or null when no user session exists.",
    responses: [
      ok: {"Current user", "application/json", Schemas.UserSessionShowResponse}
    ]

  operation :confirm, false
  operation :delete, false

  # email + password login
  def create(conn, %{"user" => %{"email" => email, "password" => password} = user_params}) do
    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> UserAuth.create_user_session(user, user_params)
      |> JSend.success_json()
    else
      conn
      |> JSend.fail_json(%{message: "failed to login"}, :unauthorized)
    end
  end

  # TODO: rate limit
  # magic link request
  def create(conn, %{"user" => %{"email" => email}}) do
    with user when not is_nil(user) <- Accounts.get_user_by_email(email),
         {:ok, _user} <-
           Accounts.deliver_login_instructions(
             user,
             &url(~p"/redirects/users/login/#{&1}")
           ) do
      JSend.success_json(conn)
    else
      nil -> JSend.fail_json(conn, %{message: "invalid email"}, :not_found)
      {:error, _reason} = error -> error
    end
  end

  # show current user
  def show(conn, _params) do
    user_details =
      if user = conn.assigns.current_scope && conn.assigns.current_scope.user do
        Accounts.get_user_details(user)
      end

    JSend.success_json(conn, %{user: user_details})
  end

  # login via magic link
  def confirm(conn, %{"token" => token} = user_params) do
    if token_user = Accounts.get_user_by_magic_link_token(token) do
      with {:ok, {user, _expired_tokens}} <- Accounts.login_user_by_magic_link(token) do
        flash =
          if token_user.confirmed_at, do: "welcome", else: "set_password"

        user_params = Map.put(user_params, "flash", flash)

        conn
        |> UserAuth.log_in_user(user, user_params)
      end
    else
      conn
      |> redirect(to: ~p"/app/login?flash=invalid_token")
    end
  end

  def delete(conn, _params) do
    conn
    |> UserAuth.log_out_user()
  end
end
