defmodule Dian.Admins do
  import Ecto.Query
  import Canada

  alias Dian.Repo
  alias Dian.Chats.User
  alias Dian.Admins.{PinnedMessage, NotificationMessage}

  def list_pinned_messages_query() do
    from message in PinnedMessage, order_by: [desc: message.inserted_at]
  end

  def list_notification_messages_query() do
    from notification_message in NotificationMessage,
      order_by: [desc: notification_message.inserted_at]
  end

  def create_pinned_message(attrs, %User{} = user) do
    pinned_message = Ecto.build_assoc(user, :pinned_messages)

    with :ok <- can?(user, create(pinned_message)) do
      pinned_message
      |> PinnedMessage.changeset(attrs)
      |> Repo.insert()
    end
  end

  def delete_pinned_message(id, %User{} = user) do
    pinned_message = Repo.get(PinnedMessage, id)

    with :ok <- can?(user, delete(pinned_message)) do
      Repo.delete(pinned_message)
    end
  end

  def create_notification_message(attrs, %User{} = user) do
    notification_message = Ecto.build_assoc(user, :notification_message)

    with :ok <- can?(user, create(notification_message)) do
      notification_message
      |> NotificationMessage.create_changeset(attrs)
      |> Repo.insert()
    end
  end

  def update_notification_message(attrs, %User{} = user) do
    notification_message = Repo.get_by(NotificationMessage, operator_id: user.id)

    with :ok <- can?(user, update(notification_message)) do
      notification_message
      |> NotificationMessage.update_changeset(attrs)
      |> Repo.update()
    end
  end
end
