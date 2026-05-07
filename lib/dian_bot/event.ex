defmodule DianBot.Event do
  alias DianBot.Message

  defmodule GroupMessageEvent do
    defstruct [:group_id, :sender_id, :message, :raw_message, :timestamp]
  end

  def build(%{"post_type" => "message", "message_type" => "group"} = payload) do
    sender_id =
      case payload["sender"] do
        %{} = sender -> sender["user_id"]
        _ -> nil
      end

    %GroupMessageEvent{
      group_id: payload["group_id"],
      sender_id: sender_id,
      message: Message.build(payload).message,
      raw_message: payload["raw_message"],
      timestamp: payload["time"]
    }
  end

  def build(_), do: nil
end
