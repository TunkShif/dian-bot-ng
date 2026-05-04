defmodule DianWeb.PasskeySessionController do
  use DianWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Dian.Accounts
  alias DianWeb.JSend
  alias DianWeb.PasskeyJSON
  alias DianWeb.Schemas
  alias DianWeb.UserAuth

  action_fallback DianWeb.FallbackController

  tags ["passkeys"]

  operation :begin,
    operation_id: "begin_passkey_login",
    summary: "Begin passkey login",
    description: "Creates WebAuthn public key credential request options for passkey login.",
    responses: [
      ok:
        {"Passkey authentication options", "application/json", Schemas.PasskeyLoginBeginResponse}
    ]

  operation :complete,
    operation_id: "complete_passkey_login",
    summary: "Complete passkey login",
    description:
      "Verifies the browser WebAuthn assertion response and starts a normal user session.",
    request_body:
      {"Passkey authentication response", "application/json", Schemas.PasskeyCredentialRequest,
       required: true},
    responses: [
      ok:
        {"Passkey login succeeded; session cookie set", "application/json", Schemas.JSendSuccess},
      bad_request:
        {"Missing authentication challenge", "application/json", Schemas.JSendMessageFail},
      unauthorized: {"Invalid passkey response", "application/json", Schemas.JSendMessageFail}
    ]

  operation :index,
    operation_id: "list_passkeys",
    summary: "List passkeys",
    description: "Returns passkeys registered by the authenticated user.",
    responses: [
      ok: {"Registered passkeys", "application/json", Schemas.PasskeyListResponse},
      unauthorized: {"Authentication required", "application/json", Schemas.JSendMessageFail}
    ]

  operation :update,
    operation_id: "update_passkey",
    summary: "Update passkey",
    description: "Updates the label for one passkey owned by the authenticated user.",
    parameters: [
      id: [in: :path, type: :integer, description: "Passkey ID", example: 1]
    ],
    request_body:
      {"Passkey update params", "application/json", Schemas.PasskeyUpdateRequest, required: true},
    responses: [
      ok: {"Updated passkey", "application/json", Schemas.PasskeyResponse},
      not_found: {"Passkey not found", "application/json", Schemas.JSendMessageFail},
      unauthorized: {"Authentication required", "application/json", Schemas.JSendMessageFail},
      unprocessable_entity: {"Validation errors", "application/json", Schemas.JSendValidationFail}
    ]

  operation :delete,
    operation_id: "delete_passkey",
    summary: "Delete passkey",
    description: "Deletes one passkey owned by the authenticated user.",
    parameters: [
      id: [in: :path, type: :integer, description: "Passkey ID", example: 1]
    ],
    responses: [
      ok: {"Passkey deleted", "application/json", Schemas.JSendSuccess},
      not_found: {"Passkey not found", "application/json", Schemas.JSendMessageFail},
      unauthorized: {"Authentication required", "application/json", Schemas.JSendMessageFail}
    ]

  def begin(conn, _params) do
    {challenge, options} = Accounts.begin_passkey_login()

    conn
    |> put_session(:webauthn_authentication_challenge, challenge)
    |> JSend.success_json(%{options: options})
  end

  def complete(conn, params) do
    with %Wax.Challenge{} = challenge <- get_session(conn, :webauthn_authentication_challenge),
         {:ok, user} <- Accounts.complete_passkey_login(challenge, params) do
      conn
      |> delete_session(:webauthn_authentication_challenge)
      |> UserAuth.create_user_session(user, params)
      |> JSend.success_json()
    else
      nil -> {:error, :passkey_authentication_challenge_not_found}
      {:error, :invalid_webauthn_response} -> {:error, :invalid_passkey_authentication_response}
      {:error, _reason} = error -> error
    end
  end

  def index(conn, _params) do
    passkeys =
      conn.assigns.current_scope
      |> Accounts.list_user_passkeys()
      |> PasskeyJSON.many()

    JSend.success_json(conn, %{passkeys: passkeys})
  end

  def update(conn, %{"id" => id} = params) do
    case Accounts.update_user_passkey(conn.assigns.current_scope, id, params) do
      {:ok, passkey} ->
        JSend.success_json(conn, %{passkey: PasskeyJSON.one(passkey)})

      {:error, _reason} = error ->
        error
    end
  end

  def delete(conn, %{"id" => id}) do
    case Accounts.delete_user_passkey(conn.assigns.current_scope, id) do
      :ok ->
        JSend.success_json(conn)

      {:error, _reason} = error ->
        error
    end
  end
end
