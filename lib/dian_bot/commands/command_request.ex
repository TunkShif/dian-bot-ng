defmodule DianBot.Commands.CommandRequest do
  @moduledoc """
  Normalized command request produced by the parser and passed to handlers.

  Fields mirror the parsed structure of a group-message slash command,
  with the original event and segments preserved for downstream use.
  """

  defstruct [
    :group_id,
    :sender_id,
    :message_id,
    :timestamp,
    :name,
    :raw_args,
    :mentions_bot?,
    :reply,
    :event,
    :segments
  ]

  @type reply :: %{message_id: String.t()}
  @type t :: %__MODULE__{
          group_id: integer(),
          sender_id: integer() | nil,
          message_id: integer() | nil,
          timestamp: integer(),
          name: String.t(),
          raw_args: String.t(),
          mentions_bot?: boolean(),
          reply: reply() | nil,
          event: DianBot.Event.GroupMessageEvent.t(),
          segments: [DianBot.Message.segment()]
        }
end
