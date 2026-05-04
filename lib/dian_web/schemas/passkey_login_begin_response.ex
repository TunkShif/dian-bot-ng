defmodule DianWeb.Schemas.PasskeyLoginBeginResponse do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "PasskeyLoginBeginResponse",
    description:
      "JSend success envelope containing WebAuthn public key credential request options.",
    type: :object,
    required: [:status, :data],
    properties: %{
      status: %Schema{type: :string, enum: ["success"], example: "success"},
      data: %Schema{
        type: :object,
        required: [:options],
        properties: %{
          options: %Schema{
            type: :object,
            required: [:challenge, :rpId, :timeout, :userVerification],
            properties: %{
              challenge: %Schema{type: :string, example: "eyJjaGFsbGVuZ2UiOiJleGFtcGxlIn0"},
              rpId: %Schema{type: :string, example: "localhost"},
              timeout: %Schema{type: :integer, example: 60_000},
              userVerification: %Schema{type: :string, example: "preferred"}
            }
          }
        }
      }
    }
  })
end
