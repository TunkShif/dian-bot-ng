defmodule DianWeb.PasskeyRegistrationController do
  use DianWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Dian.Accounts
  alias DianWeb.JSend
  alias DianWeb.PasskeyJSON
  alias DianWeb.Schemas

  action_fallback DianWeb.FallbackController

  tags ["passkeys"]

  operation :begin,
    operation_id: "begin_passkey_registration",
    summary: "Begin passkey registration",
    description:
      "Creates WebAuthn public key credential creation options for the authenticated user.",
    responses: [
      ok: {"Passkey registration options", "application/json", Schemas.PasskeyBeginResponse},
      unauthorized: {"Authentication required", "application/json", Schemas.JSendMessageFail}
    ]

  operation :complete,
    operation_id: "complete_passkey_registration",
    summary: "Complete passkey registration",
    description:
      "Verifies the browser WebAuthn attestation response and stores the passkey for the authenticated user.",
    request_body:
      {"Passkey registration response", "application/json", Schemas.PasskeyCredentialRequest,
       required: true},
    responses: [
      created: {"Registered passkey", "application/json", Schemas.PasskeyResponse},
      bad_request:
        {"Invalid registration response", "application/json", Schemas.JSendMessageFail},
      unauthorized: {"Authentication required", "application/json", Schemas.JSendMessageFail},
      unprocessable_entity: {"Validation errors", "application/json", Schemas.JSendValidationFail}
    ]

  def begin(conn, _params) do
    scope = conn.assigns.current_scope
    {challenge, options} = Accounts.begin_passkey_registration(scope)

    conn
    |> put_session(:webauthn_registration_challenge, challenge)
    |> JSend.success_json(%{options: options})
  end

  def complete(conn, params) do
    scope = conn.assigns.current_scope

    with %Wax.Challenge{} = challenge <- get_session(conn, :webauthn_registration_challenge),
         {:ok, passkey} <- Accounts.complete_passkey_registration(scope, challenge, params) do
      conn
      |> delete_session(:webauthn_registration_challenge)
      |> JSend.success_json(%{passkey: PasskeyJSON.one(passkey)}, :created)
    else
      nil -> {:error, :passkey_registration_challenge_not_found}
      {:error, :invalid_webauthn_response} -> {:error, :invalid_passkey_registration_response}
      {:error, _reason} = error -> error
    end
  end
end
