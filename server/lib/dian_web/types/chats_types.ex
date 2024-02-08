defmodule DianWeb.ChatsTypes do
  use Absinthe.Schema.Notation

  alias DianWeb.ChatsResolver

  # TODO: date type

  object :chats_queries do
    field :threads, non_null(list_of(non_null(:thread))) do
      resolve &ChatsResolver.list_threads/3
    end
  end

  object :thread do
    field :id, non_null(:id)
    field :owner, non_null(:user)
    field :group, non_null(:group)
    field :messages, non_null(list_of(:message))
    # field :posted_at, non_null(:datetime)
  end

  object :message do
    field :id, non_null(:id)
    field :sender, non_null(:user)
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
    field :type, non_null(:string) do
      resolve fn parent, _, _ -> {:ok, parent["type"]} end
    end

    field :data, non_null(:string)

    interface :message_content
  end

  object :at_message_content do
    field :type, non_null(:string)
    field :data, non_null(:at_message_content_data)

    interface :message_content
  end

  object :at_message_content_data do
    field :qid, non_null(:string)
    field :name, non_null(:string)
  end

  object :image_message_content do
    field :type, non_null(:string)
    field :data, non_null(:image_message_content_data)

    interface :message_content
  end

  object :image_message_content_data do
    field :url, non_null(:string)
  end
end
