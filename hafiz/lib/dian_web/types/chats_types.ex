defmodule DianWeb.ChatsTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  import Absinthe.Resolution.Helpers

  alias DianWeb.ChatsResolver

  object :chats_queries do
    connection field :groups, node_type: :group, non_null: true do
      resolve &ChatsResolver.list_groups/2
    end

    connection field :threads, node_type: :thread, non_null: true do
      arg :filter, :thread_filter
      resolve &ChatsResolver.list_threads/2
    end
  end

  input_object :thread_filter do
    @desc "Filtering by a user qid"
    field :user, :string
    @desc "Filtering by a group gid"
    field :group, :string
    @desc "Filtering by a specific day"
    field :date, :naive_datetime
  end

  connection(:thread, node_type: non_null(:thread), non_null: true)

  node object(:thread) do
    field :owner, non_null(:user), resolve: dataloader(Chats)
    field :group, non_null(:group), resolve: dataloader(Chats)
    field :messages, non_null(list_of(non_null(:message))), resolve: dataloader(Chats)
    field :posted_at, non_null(:naive_datetime)
  end

  node object(:message) do
    field :sender, non_null(:user), resolve: dataloader(Chats)

    field :content, non_null(list_of(non_null(:message_content))) do
      resolve &ChatsResolver.message_content/3
    end

    field :sent_at, non_null(:naive_datetime)
  end

  connection(:group, node_type: non_null(:group), non_null: true)

  node object(:group) do
    field :gid, non_null(:string)
    field :name, non_null(:string)
  end

  union :message_content do
    types [:text_message_content, :at_message_content, :image_message_content]

    resolve_type fn
      %{type: :text}, _ -> :text_message_content
      %{type: :at}, _ -> :at_message_content
      %{type: :image}, _ -> :image_message_content
      _, _ -> nil
    end
  end

  object :text_message_content do
    field :text, non_null(:string)
  end

  object :at_message_content do
    field :qid, non_null(:string)
    field :name, non_null(:string)
  end

  object :image_message_content do
    field :url, non_null(:string)
    field :width, non_null(:integer)
    field :height, non_null(:integer)
    field :blurred_url, non_null(:string)
  end
end
