defmodule DianWeb.Schemas.PasskeyUpdateRequest do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "PasskeyUpdateRequest",
    description: "Passkey update params.",
    type: :object,
    required: [:label],
    properties: %{
      label: %Schema{type: :string, minLength: 1, maxLength: 80, example: "Laptop"}
    }
  })
end
