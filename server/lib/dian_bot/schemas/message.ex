defmodule DianBot.Schemas.Message do
  use TypedStruct

  alias Dian.{Chats, Storage}
  alias DianBot.Coucou
  alias DianBot.Schemas.{User, Message}

  typedstruct do
    field :mid, String.t()
    field :sender, User.t(), enforce: true
    field :raw_text, String.t(), enforce: true
    field :content, Coucou.result()
    field :sent_at, DateTime.t(), enforce: true
  end

  @spec to_parsed(t()) :: t()
  def to_parsed(%Message{} = message) do
    case message.content do
      nil -> %Message{message | content: Coucou.parse(message.raw_text)}
      _ -> message
    end
  end

  @doc """
  Parse a message content from its raw text, then process special CQ code inside it.
  Like uploading images and resolving mentioned users.
  """
  @spec prepare(t()) :: {:ok, [t()]} | {:error, any()}
  def prepare(message) do
    try do
      message = to_parsed(message)
      messages = maybe_get_forwarded_messages!(message)

      messages =
        for message <- messages do
          Task.async(fn -> process_message!(message) end)
        end
        |> Task.await_many()

      {:ok, messages}
    rescue
      error -> {:error, error}
    end
  end

  # If the message itself is a forwarded message, get the list of messages from it.
  defp maybe_get_forwarded_messages!(%Message{} = message) do
    forwarded = Enum.find(message.content, &(&1.type == "forward"))

    if forwarded do
      case DianBot.get_forwarded_messages(forwarded.data["id"]) do
        {:ok, forwarded_messages} -> Enum.map(forwarded_messages, &to_parsed/1)
        {:error, error} -> raise error
      end
    else
      [message]
    end
  end

  defp process_message!(%Message{} = message) do
    content = Enum.map(message.content, &process_code/1)

    raw_text = for(part <- content, part.type == "text", do: part.data) |> Enum.join("\n")

    %Message{message | raw_text: raw_text, content: content}
  end

  defp process_code(%{type: "at", data: data} = item) do
    user = Chats.get_or_create_user!(data["qq"])

    %{item | data: %{qid: user.qid, name: user.name}}
  end

  defp process_code(%{type: "image", data: data} = item) do
    url =
      if Storage.exists?(data["file"]) do
        Storage.get_url(data["file"])
      else
        case Storage.upload(data) do
          {:ok, url} -> url
          {:error, error} -> raise error
        end
      end

    %{item | data: %{url: url}}
  end

  defp process_code(item), do: item
end
