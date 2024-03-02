defmodule DianWeb.SystemsResolver do
  alias Dian.Repo
  alias Dian.Admins

  @doc """
  Resolve a list of pinned messages.
  """
  def list_pinned_messages(args, _info) do
    Admins.list_pinned_messages_query()
    |> Absinthe.Relay.Connection.from_query(&Repo.all/1, args)
  end

  @doc """
  Resolve a list of notification messages.
  """
  def list_notification_messages(args, _info) do
    Admins.list_notification_messages_query()
    |> Absinthe.Relay.Connection.from_query(&Repo.all/1, args)
  end

  def create_pinned_message(_root, args, %{context: context}) do
    Admins.create_pinned_message(args, context.current_user)
  end

  def delete_pinned_message(_root, args, %{context: context}) do
    with {:ok, %{type: :pinned_message, id: id}} <-
           Absinthe.Relay.Node.from_global_id(args.id, DianWeb.Schema) do
      Admins.delete_pinned_message(id, context.current_user)
    end
  end

  def create_notification_message(_root, args, %{context: context}) do
    Admins.create_notification_message(args, context.current_user)
  end
end
