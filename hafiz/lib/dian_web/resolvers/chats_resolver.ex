defmodule DianWeb.ChatsResolver do
  alias Dian.Chats

  @doc """
  Resolve a list of threads.
  """
  def list_threads(_root, _args, _info) do
    {:ok, Chats.list_threads()}
  end

  @doc """
  Resolve the type of a message content fragment.
  """
  def message_content_type(root, _args, _info) do
    {:ok, root["type"]}
  end

  @doc """
  Resolve the data field of a message content fragment.
  """
  def message_content_data(field \\ nil) do
    fn root, _args, _info ->
      data =
        case field do
          nil -> root["data"]
          field -> root["data"][field]
        end

      {:ok, data}
    end
  end
end
