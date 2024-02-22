defmodule DianWeb.UserController do
  use DianWeb, :controller

  alias Dian.Accounts
  alias DianWeb.ErrorJSON

  def create(conn, params) do
    email = params["email"] || ""

    case Accounts.deliver_registration_email(email) do
      :ok -> send_success_resp(conn)
      {:error, error} -> send_error_resp(conn, error)
    end
  end

  def verify(conn, %{"token" => token}) do
    case Accounts.verify_email_user_token(token) do
      {:ok, _user_token} -> send_success_resp(conn)
      {:error, error} -> send_error_resp(conn, error)
    end
  end

  def confirm(conn, %{"token" => token} = params) do
    case Accounts.register_user(token, params) do
      {:ok, _user} -> send_success_resp(conn)
      {:error, error} -> send_error_resp(conn, error)
    end
  end

  defp send_success_resp(conn) do
    conn |> json(%{success: true})
  end

  defp send_error_resp(conn, %Ecto.Changeset{} = changeset) do
    conn
    |> put_status(:bad_request)
    |> json(%{success: false, reason: "invalid_params", errors: ErrorJSON.error(changeset)})
  end

  defp send_error_resp(conn, error) do
    case error do
      "already_requested" -> conn |> put_status(:too_many_requests)
      "invalid_token" -> conn |> put_status(:unauthorized)
      _ -> conn |> put_status(:bad_request)
    end
    |> json(%{success: false, reason: error})
  end
end
