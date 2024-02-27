defmodule DianWeb.NodeTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias Dian.Chats.{User, Group, Thread, Message}

  node interface do
    resolve_type fn
      %User{}, _ -> :user
      %Group{}, _ -> :group
      %Thread{}, _ -> :thread
      %Message{}, _ -> :message
      _, _ -> nil
    end
  end
end
