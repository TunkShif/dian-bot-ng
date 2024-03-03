defmodule DianWeb.NodeResolver do
  alias Dian.Repo
  alias Dian.Tracker.Activity
  alias Dian.Chats.{User, Group, Thread, Message}
  alias Dian.Admins.{PinnedMessage, NotificationMessage}

  def resolve_node(%{type: type, id: id}, _info) do
    schema =
      case type do
        :user -> User
        :group -> Group
        :thread -> Thread
        :message -> Message
        :pinned_message -> PinnedMessage
        :notification_message -> NotificationMessage
        :user_activity -> Activity
      end

    {:ok, Repo.get(schema, id)}
  end
end
