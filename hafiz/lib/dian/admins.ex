defmodule Dian.Admins do
  import Ecto.Query

  alias Dian.Repo
  alias Dian.Chats.User
  alias Dian.Admins.PinnedMessage

  def list_pinned_messages_query() do
    from message in PinnedMessage, order_by: [desc: message.inserted_at]
  end

  # TODO: handle permissions
  def create_pinned_message(attrs, %User{} = user) do
    Ecto.build_assoc(user, :pinned_messages)
    |> PinnedMessage.changeset(attrs)
    |> Repo.insert()
  end
end
