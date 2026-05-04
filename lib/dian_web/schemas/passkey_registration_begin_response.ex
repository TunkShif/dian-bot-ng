defmodule DianWeb.Schemas.PasskeyRegistrationBeginResponse do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "PasskeyRegistrationBeginResponse",
    description:
      "JSend success envelope containing WebAuthn public key credential creation options.",
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
            required: [:challenge, :rp, :user, :pubKeyCredParams, :timeout],
            properties: %{
              challenge: %Schema{type: :string, example: "eyJjaGFsbGVuZ2UiOiJleGFtcGxlIn0"},
              rp: %Schema{
                type: :object,
                required: [:id, :name],
                properties: %{
                  id: %Schema{type: :string, example: "localhost"},
                  name: %Schema{type: :string, example: "Dian"}
                }
              },
              user: %Schema{
                type: :object,
                required: [:id, :name, :displayName],
                properties: %{
                  id: %Schema{type: :string, example: "dXNlcl9pZGVudGlmaWVy"},
                  name: %Schema{type: :string, format: :email, example: "123456@qq.com"},
                  displayName: %Schema{type: :string, example: "123456"}
                }
              },
              pubKeyCredParams: %Schema{
                type: :array,
                items: %Schema{
                  type: :object,
                  required: [:type, :alg],
                  properties: %{
                    type: %Schema{type: :string, example: "public-key"},
                    alg: %Schema{type: :integer, example: -7}
                  }
                }
              },
              timeout: %Schema{type: :integer, example: 60_000},
              authenticatorSelection: %Schema{
                type: :object,
                required: [:residentKey, :requireResidentKey, :userVerification],
                properties: %{
                  residentKey: %Schema{type: :string, example: "required"},
                  requireResidentKey: %Schema{type: :boolean, example: true},
                  userVerification: %Schema{type: :string, example: "preferred"}
                }
              }
            }
          }
        }
      }
    }
  })
end
