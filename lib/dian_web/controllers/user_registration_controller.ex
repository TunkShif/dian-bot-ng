defmodule DianWeb.UserRegistrationController do
  use DianWeb, :controller

  alias DianWeb.JSend
  alias Dian.Accounts

  action_fallback DianWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, user} <- Accounts.register_user(user_params),
         {:ok, _} <-
           Accounts.deliver_login_instructions(user, &url(~p"/redirects/users/login/#{&1}")) do
      conn
      |> JSend.success_json()
    end
  end
end
