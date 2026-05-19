defmodule DianBot.Commands.Parser do
  @moduledoc """
  Parses `GroupMessageEvent` into `CommandRequest` using normalized segments.

  ## Recognized message shape

      [optional reply segment] [optional @bot segment] [text segment starting with "/"]

  Any non-structural segment (image, face, etc.) or an @mention of a different
  user before the command text causes the message to be ignored.
  """

  alias DianBot.Commands.CommandRequest
  alias DianBot.Event.GroupMessageEvent

  @doc """
  Parses a group-message event into a command request.

  The bot's own user id is read from `event.self_id` to determine whether
  an @-mention targets this bot.

  Returns `{:ok, %CommandRequest{}}` when a valid slash command is found,
  or `:ignore` when the message does not match the expected shape.
  """
  @spec parse(%GroupMessageEvent{}) :: {:ok, %CommandRequest{}} | :ignore
  def parse(%GroupMessageEvent{} = event) do
    segments = event.message

    case do_parse(segments, event.self_id) do
      {:ok, reply, mentions_bot?, name, raw_args} ->
        {:ok,
         %CommandRequest{
           group_id: event.group_id,
           sender_id: event.sender_id,
           message_id: event.message_id,
           timestamp: event.timestamp,
           name: name,
           raw_args: raw_args,
           mentions_bot?: mentions_bot?,
           reply: reply,
           event: event,
           segments: event.message
         }}

      :ignore ->
        :ignore
    end
  end

  defp do_parse([%{type: "reply", data: %{"id" => id}} | rest], bot_id) do
    do_parse_after_reply(rest, bot_id, %{message_id: id})
  end

  defp do_parse(segments, bot_id) do
    do_parse_after_reply(segments, bot_id, nil)
  end

  defp do_parse_after_reply([%{type: "at", data: %{"qq" => qq}} | rest], bot_id, reply) do
    if to_string(qq) == to_string(bot_id) do
      do_parse_command(rest, reply, true)
    else
      :ignore
    end
  end

  defp do_parse_after_reply(segments, _bot_id, reply) do
    do_parse_command(segments, reply, false)
  end

  defp do_parse_command([%{type: "text", data: %{"text" => text}}], reply, mentions_bot?) do
    trimmed = String.trim_leading(text)

    if String.starts_with?(trimmed, "/") do
      <<"/", rest::binary>> = trimmed
      rest = String.trim_leading(rest)
      [name | tail] = String.split(rest, ~r/\s+/, parts: 2)

      {:ok, reply, mentions_bot?, name || "", List.first(tail) || ""}
    else
      :ignore
    end
  end

  defp do_parse_command(_segments, _reply, _mentions_bot?), do: :ignore
end
