defmodule DianWeb.Schemas.JSendMessageFail do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "JSendMessageFail",
    description: "JSend fail envelope with a message.",
    type: :object,
    required: [:status, :data],
    properties: %{
      status: %Schema{type: :string, enum: ["fail"], example: "fail"},
      data: %Schema{
        type: :object,
        required: [:message],
        properties: %{
          message: %Schema{type: :string, example: "failed to login"}
        }
      }
    },
    example: %{
      "status" => "fail",
      "data" => %{
        "message" => "failed to login"
      }
    }
  })
end
