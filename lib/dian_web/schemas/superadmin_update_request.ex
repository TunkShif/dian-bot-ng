defmodule DianWeb.Schemas.SuperadminUpdateRequest do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "SuperadminUpdateRequest",
    description: "Request body for updating the superadmin user.",
    type: :object,
    required: [:user_id],
    properties: %{
      user_id: %Schema{type: :integer, description: "ID of the user to set as superadmin"}
    }
  })
end
