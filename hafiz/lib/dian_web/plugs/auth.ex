defmodule DianWeb.Auth do
  import Plug.Conn

  alias Dian.Accounts
  alias Dian.Chats.User

  def fetch_current_user(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         dbg(token),
         %User{} = user <- Accounts.get_user_by_session_token(token) do
      assign(conn, :current_user, user)
    else
      _ -> conn
    end
  end
end
