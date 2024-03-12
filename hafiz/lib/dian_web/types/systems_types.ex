defmodule DianWeb.SystemsTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  import Absinthe.Resolution.Helpers

  alias DianWeb.SystemsResolver

  object :systems_queries do
    connection field :pinned_messages, node_type: :pinned_message, non_null: true do
      resolve &SystemsResolver.list_pinned_messages/2
    end

    connection field :notification_messages, node_type: :notification_message, non_null: true do
      resolve &SystemsResolver.list_notification_messages/2
    end
  end

  object :systems_mutations do
    field :create_pinned_message, type: :pinned_message do
      arg :type, non_null(:pinned_message_type)
      arg :title, non_null(:string)
      arg :content, non_null(:string)

      resolve &SystemsResolver.create_pinned_message/3
    end

    field :delete_pinned_message, type: :pinned_message do
      arg :id, non_null(:id)

      resolve &SystemsResolver.delete_pinned_message/3
    end

    @desc "Create or update a notification message template for user"
    field :create_notification_message, type: :notification_message do
      arg :template, non_null(:string)

      resolve &SystemsResolver.create_notification_message/3
    end

    field :create_broadcast_message, type: :boolean do
      arg :group_id, non_null(:string)
      arg :message, non_null(:string)

      resolve &SystemsResolver.create_broadcast_message/3
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

  connection(:notification_message, node_type: non_null(:notification_message), non_null: true)

  node object(:notification_message) do
    field :template, non_null(:string)
    field :operator, non_null(:user), resolve: dataloader(Chats)
  end
end
