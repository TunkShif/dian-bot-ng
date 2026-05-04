defmodule DianWeb.Schemas.GroupResponse do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "GroupResponse",
    description: "JSend success envelope containing one DianBot group and its members.",
    type: :object,
    required: [:status, :data],
    properties: %{
      status: %Schema{type: :string, enum: ["success"], example: "success"},
      data: %Schema{
        type: :object,
        required: [:group],
        properties: %{
          group: %Schema{
            type: :object,
            required: [
              :avatar_url,
              :group_id,
              :group_name,
              :group_remark,
              :member_count,
              :enabled,
              :is_admin,
              :members
            ],
            properties: %{
              avatar_url: %Schema{type: :string, example: "https://p.qlogo.cn/gh/100/100/640/"},
              group_id: %Schema{type: :integer, example: 100},
              group_name: %Schema{type: :string, example: "Dian Group"},
              group_remark: %Schema{type: :string, nullable: true, example: ""},
              member_count: %Schema{type: :integer, example: 42},
              enabled: %Schema{type: :boolean, example: true},
              is_admin: %Schema{type: :boolean, example: false},
              members: %Schema{
                type: :array,
                items: %Schema{
                  type: :object,
                  required: [
                    :user_id,
                    :group_id,
                    :nickname,
                    :display_name,
                    :avatar_url,
                    :join_time,
                    :last_sent_time,
                    :is_robot,
                    :role,
                    :title
                  ],
                  properties: %{
                    user_id: %Schema{type: :integer, example: 12345},
                    group_id: %Schema{type: :integer, example: 100},
                    nickname: %Schema{type: :string, example: "Dian User"},
                    display_name: %Schema{type: :string, nullable: true, example: "Dian User"},
                    avatar_url: %Schema{
                      type: :string,
                      example: "https://q1.qlogo.cn/g?b=qq&nk=12345&s=640"
                    },
                    join_time: %Schema{type: :integer, example: 1_700_000_000},
                    last_sent_time: %Schema{type: :integer, example: 1_700_000_000},
                    is_robot: %Schema{type: :boolean, example: false},
                    role: %Schema{
                      type: :string,
                      enum: ["owner", "admin", "member"],
                      example: "member"
                    },
                    title: %Schema{type: :string, nullable: true, example: ""}
                  }
                }
              }
            }
          }
        }
      }
    }
  })
end
