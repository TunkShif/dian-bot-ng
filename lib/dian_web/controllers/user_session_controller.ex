defmodule DianWeb.UserSessionController do
  use DianWeb, :controller

  alias DianWeb.JSend
  alias Dian.Accounts
  alias DianWeb.UserAuth

  action_fallback DianWeb.FallbackController

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
