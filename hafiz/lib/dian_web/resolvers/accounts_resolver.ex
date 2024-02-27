defmodule DianWeb.AccountsResolver do
  alias Dian.{Repo, Chats}
  alias Dian.Chats.User

  def current_user(_root, _args, %{context: context}) do
    {:ok, context[:current_user]}
  end

  def user_threads(args, %{source: %User{} = user}) do
    Chats.list_user_threads_query(user.id)
    |> Absinthe.Relay.Connection.from_query(&Repo.all/1, args)
  end

  def user_statistics(root, _args, _info) do
    {:ok, Chats.get_user_statistics(root.id)}
  end
end
