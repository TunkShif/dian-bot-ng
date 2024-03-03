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

  def get_default_notification_message() do
    # TODO: get default notification from global settings
    Repo.one(
      from notification_message in NotificationMessage,
        order_by: [desc: notification_message.updated_at],
        limit: 1
    )
  end

  @doc """
  Returns the notification message of given user or the default notification message
  """
  def get_user_notfication_message(user_id) do
    notification =
      Repo.one(from notification_message in NotificationMessage, where: [operator_id: ^user_id])

    notification || get_default_notification_message()
  end

  def create_notification_message(attrs, %User{} = user) do
    notification_message = Ecto.build_assoc(user, :notification_message)

    with :ok <- can?(user, create(notification_message)) do
      notification_message
      |> NotificationMessage.changeset(attrs)
      |> Repo.insert(
        on_conflict: [set: [template: attrs.template]],
        conflict_target: :operator_id
      )
    end
  end
end
