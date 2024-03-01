defmodule DianWeb.SystemsTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  import Absinthe.Resolution.Helpers

  alias Dian.Chats
  alias DianWeb.SystemsResolver

  object :systems_queries do
    connection field :pinned_messages, node_type: :pinned_message, non_null: true do
      resolve &SystemsResolver.list_pinned_messages/2
    end
  end

  object :systems_mutations do
    field :create_pinned_message, type: :pinned_message do
      arg :type, non_null(:pinned_message_type)
      arg :title, non_null(:string)
      arg :content, non_null(:string)

      resolve &SystemsResolver.create_pinned_message/3
    end
  end

  connection(:pinned_message, node_type: non_null(:pinned_message), non_null: true)

  node object(:pinned_message) do
    field :type, non_null(:pinned_message_type)
    field :title, non_null(:string)
    field :content, non_null(:string)
    field :operator, non_null(:user), resolve: dataloader(Chats)
  end

  enum :pinned_message_type do
    value :info
    value :alert
    value :news
  end
end
