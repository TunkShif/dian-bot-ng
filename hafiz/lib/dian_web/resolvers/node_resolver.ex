defmodule DianWeb.NodeResolver do
  alias Dian.Repo
  alias Dian.Chats.{User, Group, Thread, Message}

  def resolve_node(%{type: type, id: id}, _info) do
    schema =
      case type do
        :user -> User
        :group -> Group
        :thread -> Thread
        :message -> Message
      end

    {:ok, Repo.get(schema, id)}
  end
end
