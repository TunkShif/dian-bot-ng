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
      ok: {"Magic login link accepted", "application/json", Schemas.JSendSuccess},
      found: "Password login succeeded; redirects to the SPA",
      unauthorized: {"Invalid password credentials", "application/json", Schemas.JSendMessageFail}
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
      |> put_flash(:info, "flash.welcome")
      |> UserAuth.log_in_user(user, user_params)
    else
      conn
      |> JSend.fail_json(%{message: "failed to login"}, :unauthorized)
    end
  end

  # magic link request
  def create(conn, %{"user" => %{"email" => email}}) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_login_instructions(
        user,
        &url(~p"/redirects/users/login/#{&1}")
      )
    end

    JSend.success_json(conn)
  end

  # show current user
  def show(conn, _params) do
    maybe_user = conn.assigns.current_scope && conn.assigns.current_scope.user
    JSend.success_json(conn, %{user: maybe_user})
  end

  # login via magic link
  def confirm(conn, %{"token" => token} = user_params) do
    if token_user = Accounts.get_user_by_magic_link_token(token) do
      with {:ok, {user, _expired_tokens}} <- Accounts.login_user_by_magic_link(token) do
        message =
          if token_user.confirmed_at, do: "flash.welcome", else: "flash.set_password_prompt"

        conn
        |> put_flash(:info, message)
        |> UserAuth.log_in_user(user, user_params)
      end
    else
      conn
      |> put_flash(:error, "flash.invalid_token")
      |> redirect(to: ~p"/app/login")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "flash.logout")
    |> UserAuth.log_out_user()
  end
end
