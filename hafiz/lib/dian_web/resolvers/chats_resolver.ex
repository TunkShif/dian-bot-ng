defmodule DianWeb.ChatsResolver do
  alias Dian.Repo
  alias Dian.Chats

  @doc """
  Resolve a list of threads.
  """
  def list_threads(args, _info) do
    Chats.list_threads_query()
    |> Absinthe.Relay.Connection.from_query(&Repo.all/1, args)
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
