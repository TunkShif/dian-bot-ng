defmodule DianWeb.ChatsResolver do
  alias Dian.Chats

  def list_threads(_root, _args, _info) do
    {:ok, Chats.list_threads()}
  end
end
