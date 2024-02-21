defmodule DianWeb.SessionController do
  use DianWeb, :controller

  alias Dian.Accounts

  def create(conn, params) do
    # TODO: get request source ip
    device = get_req_header(conn, "user-agent") |> List.first()
    params = params |> Map.put("device", device)

    case Accounts.login_user(params) do
      nil ->
        send_unauthorized_resp(conn)

      token ->
        conn
        |> put_resp_header("authorization", "Bearer #{token}")
        |> json(%{success: true})
    end
  end

  def delete(conn, _params) do
    case get_auth_token(conn) do
      nil ->
        send_unauthorized_resp(conn)

      token ->
        Accounts.delete_user_session_token(token)
        conn |> json(%{success: true})
    end
  end

  defp get_auth_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> token
      _ -> nil
    end
  end

  defp send_unauthorized_resp(conn) do
    conn
    |> put_status(:unauthorized)
    |> json(%{success: false})
  end
end
