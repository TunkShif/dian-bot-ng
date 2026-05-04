defmodule DianWeb.Schemas.GroupUpdateRequest do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "GroupUpdateRequest",
    description: "Group settings update params.",
    type: :object,
    required: [:enabled],
    properties: %{
      enabled: %Schema{type: :boolean, example: true}
    }
  })
end
