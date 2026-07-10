defmodule DianBot.Commands.Handlers.ThreadAppend do
  @moduledoc """
  Batch workflow for collecting messages and saving them into a thread.

  ## Commands

    * `/thread:append` (aliases: `/ssj`, `/rrd`) — collects a replied-to message
    * `/thread:done` (alias: `/done`) — flushes all collected messages into a thread

  ## Usage

      (reply to a message) /thread:append
      (reply to another message) /thread:append
      /thread:done
  """

  use DianBot.Commands.BatchWorkflow

  @impl true
  def cmds do
    [
      %Entry{
        type: :batch_collect,
        module: __MODULE__,
        command: "thread:append",
        aliases: ["ssj", "rrd"],
        reply_required?: true,
        usage: "/thread:append"
      },
      %Entry{
        type: :batch_flush,
        module: __MODULE__,
        command: "thread:done",
        aliases: ["done"],
        usage: "/thread:done"
      }
    ]
  end

  @impl true
  def workflow, do: :thread_append

  @impl true
  def timeout_ms, do: :timer.minutes(5)

  @impl true
  def scope(%CommandRequest{group_id: group_id, sender_id: sender_id}) do
    {group_id, sender_id}
  end

  @impl true
  def parse_args("", _extra_segments), do: {:ok, nil}
  def parse_args(_other, _extra_segments), do: {:error, "no arguments expected"}

  @impl true
  def collect(%CommandRequest{} = request, nil) do
    case Dian.Threads.collect_message(request.reply.message_id) do
      {:ok, msg_attrs} -> {:ok, msg_attrs}
      {:error, :fetch_failed} -> {:error, "could not fetch message"}
    end
  end

  @impl true
  def flush({group_id, sender_id}, collected, _reason) do
    case Dian.Threads.batch_save_messages(
           to_string(group_id),
           to_string(sender_id),
           collected
         ) do
      {:ok, %{messages: messages}} ->
        {:reply, "Saved #{length(messages)} messages ✓"}

      {:error, changeset} ->
        {:reply, "Error: #{inspect(changeset.errors)}"}
    end
  end
end
