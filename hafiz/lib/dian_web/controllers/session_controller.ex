defmodule DianWeb.SessionController do
  use DianWeb, :controller

  alias Dian.Accounts

  def create(conn, params) do
    # TODO: get request source ip
    device = get_req_header(conn, "user-agent") |> List.first()
    params = params |> Map.put("device", device)

    if token = Accounts.login_user(params) do
      conn
      |> put_resp_header("authorization", "Bearer #{token}")
      |> json(%{success: true})
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{success: false})
    end
  end

  def delete(conn, _params) do
    user = conn.assigns[:current_user]
    dbg(user)

    if user do
      json(conn, %{success: true})
    else
      json(conn, %{success: false})
    end
  end
end
