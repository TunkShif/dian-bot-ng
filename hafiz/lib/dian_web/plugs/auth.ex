defmodule DianWeb.Auth do
  import Plug.Conn

  alias Dian.Accounts
  alias Dian.Chats.User

  def fetch_current_user(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         %User{} = user <- Accounts.get_user_by_session_token(token) do
      assign(conn, :current_user, user)
    else
      _ -> conn
    end
  end

  def put_user_context(conn, _opts) do
    context =
      case conn.assigns[:current_user] do
        %User{} = current_user -> %{current_user: current_user}
        _ -> %{}
      end

    Absinthe.Plug.put_options(conn, context: context)
  end
end
