defmodule DianBot.Event do
  alias DianBot.Message

  defmodule GroupMessageEvent do
    @type t :: %__MODULE__{
            self_id: integer() | nil,
            group_id: integer(),
            sender_id: integer() | nil,
            message_id: integer() | nil,
            message: [DianBot.Message.segment()],
            raw_message: String.t(),
            timestamp: integer()
          }

    defstruct [:self_id, :group_id, :sender_id, :message_id, :message, :raw_message, :timestamp]
  end

  def build(%{"post_type" => "message", "message_type" => "group"} = payload) do
    sender_id =
      case payload["sender"] do
        %{} = sender -> sender["user_id"]
        _ -> nil
      end

    %GroupMessageEvent{
      self_id: payload["self_id"],
      group_id: payload["group_id"],
      sender_id: sender_id,
      message_id: payload["message_id"],
      message: Message.build(payload).message,
      raw_message: payload["raw_message"],
      timestamp: payload["time"]
    }
  end

  def build(_), do: nil
end
