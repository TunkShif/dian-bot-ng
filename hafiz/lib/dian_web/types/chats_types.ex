defmodule DianWeb.ChatsTypes do
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers

  alias Dian.Chats
  alias DianWeb.ChatsResolver

  # TODO: custom datetime scalar type

  object :chats_queries do
    field :threads, non_null(list_of(non_null(:thread))) do
      resolve &ChatsResolver.list_threads/3
    end
  end

  object :thread do
    field :id, non_null(:id)
    field :owner, non_null(:user), resolve: dataloader(Chats)
    field :group, non_null(:group), resolve: dataloader(Chats)
    field :messages, non_null(list_of(:message)), resolve: dataloader(Chats)
    # field :posted_at, non_null(:datetime)
  end

  object :message do
    field :id, non_null(:id)
    field :sender, non_null(:user), resolve: dataloader(Chats)
    field :content, non_null(list_of(non_null(:message_content)))
    # field :sent_at, non_null(:datetime)
  end

  object :group do
    field :id, non_null(:id)
    field :gid, non_null(:string)
    field :name, non_null(:string)
  end

  # TODO: how to typing message_content

  interface :message_content do
    field :type, non_null(:string)

    resolve_type fn
      %{"type" => "text"}, _ -> :text_message_content
      %{"type" => "at"}, _ -> :at_message_content
      %{"type" => "image"}, _ -> :image_message_content
      _, _ -> nil
    end
  end

  object :text_message_content do
    field :type, non_null(:string), resolve: &ChatsResolver.message_content_type/3
    field :text, non_null(:string), resolve: ChatsResolver.message_content_data()

    interface :message_content
  end

  object :at_message_content do
    field :type, non_null(:string), resolve: &ChatsResolver.message_content_type/3
    field :qid, non_null(:string), resolve: ChatsResolver.message_content_data("qid")
    field :name, non_null(:string), resolve: ChatsResolver.message_content_data("name")

    interface :message_content
  end

  object :image_message_content do
    field :type, non_null(:string), resolve: &ChatsResolver.message_content_type/3
    field :url, non_null(:string), resolve: ChatsResolver.message_content_data("url")

    interface :message_content
  end
end
