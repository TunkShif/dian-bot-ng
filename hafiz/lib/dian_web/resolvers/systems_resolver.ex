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

  # TODO: handle changeset error format
  def create_pinned_message(_root, args, %{context: context}) do
    Admins.create_pinned_message(args, context.current_user)
  end
end
