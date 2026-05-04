defmodule DianWeb.Schemas.GroupListResponse do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "GroupListResponse",
    description: "JSend success envelope containing DianBot groups visible to the current user.",
    type: :object,
    required: [:status, :data],
    properties: %{
      status: %Schema{type: :string, enum: ["success"], example: "success"},
      data: %Schema{
        type: :object,
        required: [:groups],
        properties: %{
          groups: %Schema{
            type: :array,
            items: %Schema{
              type: :object,
              required: [
                :avatar_url,
                :group_id,
                :group_name,
                :group_remark,
                :member_count,
                :enabled,
                :is_admin
              ],
              properties: %{
                avatar_url: %Schema{type: :string, example: "https://p.qlogo.cn/gh/100/100/640/"},
                group_id: %Schema{type: :integer, example: 100},
                group_name: %Schema{type: :string, example: "Dian Group"},
                group_remark: %Schema{type: :string, nullable: true, example: ""},
                member_count: %Schema{type: :integer, example: 42},
                enabled: %Schema{type: :boolean, example: true},
                is_admin: %Schema{type: :boolean, example: false}
              }
            }
          }
        }
      }
    }
  })
end
