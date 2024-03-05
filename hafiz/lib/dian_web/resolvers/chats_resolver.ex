defmodule DianWeb.ChatsResolver do
  alias Dian.Repo
  alias Dian.Chats
  alias Dian.Chats.Image

  @doc """
  Resolve a list of threads.
  """
  def list_threads(args, _info) do
    Chats.list_threads_query()
    |> Absinthe.Relay.Connection.from_query(&Repo.all/1, args)
  end

  def message_content(root, _args, _info) do
    {:ok, Enum.map(root.content, &resolve_message_content/1)}
  end

  defp resolve_message_content(%{"type" => "text"} = content) do
    %{type: :text, text: content["data"]}
  end

  defp resolve_message_content(%{"type" => "at"} = content) do
    %{type: :at, qid: content["data"]["qid"], name: content["data"]["name"]}
  end

  # TODO: batch image query

  defp resolve_message_content(%{"type" => "image", "data" => %{"id" => id}}) do
    image = Repo.get(Image, id)

    %{
      type: :image,
      url: image.url,
      width: image.width,
      height: image.height,
      blurred_url: "data:image/webp;base64,#{image.blurred_data}"
    }
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
