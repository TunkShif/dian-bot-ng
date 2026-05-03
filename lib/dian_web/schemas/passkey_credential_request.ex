defmodule DianWeb.Schemas.PasskeyCredentialRequest do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "PasskeyCredentialRequest",
    description: "WebAuthn credential response from the browser.",
    type: :object,
    required: [:response],
    properties: %{
      rawId: %Schema{
        type: :string,
        description: "Base64url encoded credential id.",
        example: "0AcQWg"
      },
      label: %Schema{
        type: :string,
        description: "Optional user-facing passkey label for registration.",
        example: "Laptop"
      },
      response: %Schema{
        type: :object,
        additionalProperties: true,
        example: %{
          "attestationObject" => "o2NmbXRkbm9uZQ",
          "clientDataJSON" => "eyJ0eXBlIjoid2ViYXV0aG4uY3JlYXRlIn0",
          "authenticatorData" => "SZYN5YgOjGh0NBcPZHZgW4_krrmih3F9dxqY",
          "signature" => "MEUCIQD",
          "userHandle" => "xsKJ5J6cBbIUWGA4e3O8sY30P7CaHkpKlxPHbIi7VBs"
        }
      }
    }
  })
end
