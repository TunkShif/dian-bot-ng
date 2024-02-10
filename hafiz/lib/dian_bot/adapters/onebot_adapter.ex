defmodule DianBot.Adapters.OnebotAdapter do
  @behaviour DianBot.Adapter

  # TODO: considering cache request result

  use Tesla, only: [:get, :post]

  alias DianBot.BotError
  alias DianBot.Schemas.{User, Group, Message, Event}

  plug Tesla.Middleware.BaseUrl, base_url()
  plug Tesla.Middleware.Headers, [{"authorization", access_token()}]
  plug Tesla.Middleware.JSON

  defp config, do: Application.fetch_env!(:dian, DianBot)
  defp base_url, do: config() |> Keyword.fetch!(:base_url)
  defp access_token, do: config() |> Keyword.fetch!(:access_token)

  @impl true
  def is_online() do
    with {:ok, response} <- get("/get_status"),
         {:ok, data} <- handle_response(response) do
      data["online"]
    else
      _ -> false
    end
  end

  @impl true
  def get_user(qid) do
    with {:ok, response} <- get("/get_stranger_info", query: [user_id: qid]),
         {:ok, data} <- handle_response(response) do
      {:ok, %User{qid: to_string(qid), nickname: data["nickname"]}}
    end
  end

  @impl true
  def get_group(gid) do
    with {:ok, response} <- get("/get_group_info", query: [group_id: gid]),
         {:ok, data} <- handle_response(response) do
      {:ok,
       %Group{gid: to_string(gid), name: data["group_name"], description: data["group_memo"]}}
    end
  end

  @impl true
  def get_message(mid) do
    with {:ok, response} <- get("/get_msg", query: [message_id: mid]),
         {:ok, data} <- handle_response(response),
         {:ok, sender} <- get_user(data["sender"]["user_id"]) do
      {:ok,
       %Message{
         mid: mid,
         sender: sender,
         raw_text: data["message"],
         sent_at: data["time"] |> DateTime.from_unix!()
       }}
    end
  end

  @impl true
  def get_forwarded_messages(mid) do
    with {:ok, response} <- get("/get_forward_msg", query: [message_id: mid]),
         {:ok, data} <- handle_response(response) do
      parse_forwarded_messages(data["messages"])
    end
  end

  defp parse_forwarded_messages(messages) do
    try do
      messages =
        for message <- messages do
          with {:ok, sender} <- get_user(message["sender"]["user_id"]) do
            %Message{
              sender: sender,
              raw_text: message["content"],
              sent_at: message["time"] |> DateTime.from_unix!()
            }
          else
            {:error, error} -> raise error
          end
        end

      {:ok, messages}
    rescue
      error -> {:error, error}
    end
  end

  @impl true
  def send_group_message(gid, message) do
    with {:ok, response} <- post("/send_group_msg", %{group_id: gid, message: message}),
         {:ok, _data} <- handle_response(response) do
      :ok
    end
  end

  @impl true
  def set_honorable_message(mid) do
    with {:ok, response} <- post("/set_essence_msg", %{message_id: mid}),
         {:ok, _data} <- handle_response(response) do
      :ok
    end
  end

  @impl true
  def parse_event(data, opts) do
    payload = opts |> Keyword.get(:payload)
    signature = opts |> Keyword.get(:signature)

    case trusted_event?(payload, signature) do
      true -> build_event(data)
      false -> {:error, %BotError{message: "unauthorized event source"}}
    end
  end

  defp build_event(data) do
    %{"mid" => mid} = Regex.named_captures(~r/\[CQ:reply,id=(?<mid>-?\d+)\]/, data["raw_message"])

    with {:ok, owner} <- get_user(data["sender"]["user_id"]),
         {:ok, group} <- get_group(data["group_id"]),
         {:ok, message} <- get_message(mid) do
      {:ok,
       %Event{
         id: data["message_id"],
         message: message,
         owner: owner,
         group: group,
         marked_at: data["time"] |> DateTime.from_unix!()
       }}
    end
  end

  defp secret, do: config() |> Keyword.fetch!(:secret)

  defp trusted_event?(payload, signature) when is_binary(payload) and is_binary(signature) do
    hmac = :crypto.mac(:hmac, :sha, secret(), payload)
    actual_signature = Base.encode16(hmac, case: :lower)
    signature == "sha1=" <> actual_signature
  end

  defp trusted_event?(_body, _signature), do: false

  defp handle_response(%Tesla.Env{} = response) do
    case response do
      %{status: 200, body: %{"status" => "ok"} = body} -> {:ok, body["data"]}
      %{status: 200, body: body} -> {:error, %BotError{message: body["msg"]}}
      %{status: 404} -> {:error, %BotError{message: "unknown bot api"}}
      _ -> {:error, %BotError{message: "bot api error"}}
    end
  end
end
