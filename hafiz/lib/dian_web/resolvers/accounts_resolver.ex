defmodule DianWeb.AccountsResolver do
  alias Dian.{Chats, Admins}

  def me(_root, _args, _info) do
    {:ok, %{}}
  end

  def current_user(_root, _args, %{context: context}) do
    {:ok, context[:current_user]}
  end

  def user_token(_root, _args, %{context: context}) do
    {:ok, context[:token]}
  end

  def user_statistics(_root, _args, %{context: context}) do
    {:ok, Chats.get_user_statistics(context.current_user.id)}
  end

  def user_notification_message(_root, _args, %{context: context}) do
    {:ok, Admins.get_user_notfication_message(context.current_user.id)}
  end
end
