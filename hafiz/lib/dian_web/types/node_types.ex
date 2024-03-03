defmodule DianWeb.NodeTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias Dian.Tracker.Activity
  alias Dian.Chats.{User, Group, Thread, Message}
  alias Dian.Admins.{PinnedMessage, NotificationMessage}

  node interface do
    resolve_type fn
      %User{}, _ -> :user
      %Group{}, _ -> :group
      %Thread{}, _ -> :thread
      %Message{}, _ -> :message
      %PinnedMessage{}, _ -> :pinned_message
      %NotificationMessage{}, _ -> :notification_message
      %Activity{}, _ -> :user_activity
      _, _ -> nil
    end
  end
end
