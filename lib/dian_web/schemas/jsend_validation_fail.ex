defmodule DianWeb.Schemas.JSendValidationFail do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "JSendValidationFail",
    description: "JSend fail envelope containing field validation errors.",
    type: :object,
    required: [:status, :data],
    properties: %{
      status: %Schema{type: :string, enum: ["fail"], example: "fail"},
      data: %Schema{
        type: :object,
        additionalProperties: %Schema{
          type: :array,
          items: %Schema{type: :string}
        },
        example: %{
          "email" => ["must be a QQ email"]
        }
      }
    },
    example: %{
      "status" => "fail",
      "data" => %{
        "email" => ["must be a QQ email"]
      }
    }
  })
end
