defmodule DianWeb.Schemas.JSendSuccess do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "JSendSuccess",
    description: "JSend success envelope.",
    type: :object,
    required: [:status, :data],
    properties: %{
      status: %Schema{type: :string, enum: ["success"], example: "success"},
      data: %Schema{nullable: true, example: nil}
    },
    example: %{
      "status" => "success",
      "data" => nil
    }
  })
end
