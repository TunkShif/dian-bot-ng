defmodule DianWeb.AccountsResolver do
  alias Dian.Repo
  alias Dian.{Admins, Accounts}
  alias Dian.Chats.User

  @doc """
  Resolve a list of users.
  """
  def list_users(args, _info) do
    Accounts.list_users_query()
    |> Absinthe.Relay.Connection.from_query(&Repo.all/1, args)
  end

  def me(_root, _args, _info) do
    {:ok, %{}}
  end

  def current_user(_root, _args, %{context: context}) do
    {:ok, context[:current_user]}
  end

  def user_token(_root, _args, %{context: context}) do
    {:ok, context[:token]}
  end

  def user_perms(_root, _args, %{context: context}) do
    {:ok, User.perms(context.current_user)}
  end

  def user_registered(root, _args, %{context: context}) do
    registered? =
      case User.admin?(context.current_user) do
        true -> root.hashed_password != nil
        false -> nil
      end

    {:ok, registered?}
  end

  def user_notification_message(_root, _args, %{context: context}) do
    {:ok, Admins.get_user_notfication_message(context.current_user.id)}
  end

  def update_user_role(_root, args, %{context: context}) do
    with {:ok, %{type: :user, id: id}} <-
           Absinthe.Relay.Node.from_global_id(args.id, DianWeb.Schema) do
      Accounts.update_user(id, %{role: args.role}, context.current_user)
    end
  end

  def cancel_user_account(_root, args, %{context: context}) do
    with {:ok, %{type: :user, id: id}} <-
           Absinthe.Relay.Node.from_global_id(args.id, DianWeb.Schema) do
      Accounts.update_user(id, %{hashed_password: nil}, context.current_user)
    end
  end
end
