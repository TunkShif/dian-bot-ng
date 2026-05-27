defmodule DianWeb.FallbackController do
  use DianWeb, :controller

  require Logger

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: DianWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: DianWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> json(DianWeb.JSend.fail(%{message: "forbidden"}))
  end

  # TODO: unified common error struct
  def call(conn, {:error, :passkey_registration_challenge_not_found}) do
    conn
    |> put_status(:bad_request)
    |> json(DianWeb.JSend.fail(%{message: "passkey registration challenge not found"}))
  end

  def call(conn, {:error, :invalid_passkey_registration_response}) do
    conn
    |> put_status(:bad_request)
    |> json(DianWeb.JSend.fail(%{message: "invalid passkey registration response"}))
  end

  def call(conn, {:error, :passkey_authentication_challenge_not_found}) do
    conn
    |> put_status(:bad_request)
    |> json(DianWeb.JSend.fail(%{message: "passkey authentication challenge not found"}))
  end

  def call(conn, {:error, :passkey_not_found}) do
    conn
    |> put_status(:unauthorized)
    |> json(DianWeb.JSend.fail(%{message: "passkey not found"}))
  end

  def call(conn, {:error, :invalid_passkey_authentication_response}) do
    conn
    |> put_status(:unauthorized)
    |> json(DianWeb.JSend.fail(%{message: "invalid passkey authentication response"}))
  end

  def call(conn, {:error, :not_bound}) do
    conn
    |> put_status(:not_found)
    |> json(DianWeb.JSend.fail(%{message: "no Steam binding found for this QQ ID"}))
  end

  def call(conn, {:error, :steam_api_error}) do
    conn
    |> put_status(:bad_gateway)
    |> json(DianWeb.JSend.fail(%{message: "failed to fetch Steam player summary"}))
  end

  def call(conn, {:error, {:email_delivery_failed, _reason}}) do
    conn
    |> put_status(:bad_gateway)
    |> json(DianWeb.JSend.fail(%{message: "failed to send email"}))
  end

  def call(conn, {:error, reason}) do
    Logger.error("unhandled action_fallback error: #{inspect(reason)}")

    conn
    |> put_status(:internal_server_error)
    |> json(DianWeb.JSend.fail(%{message: "internal server error"}))
  end
end
