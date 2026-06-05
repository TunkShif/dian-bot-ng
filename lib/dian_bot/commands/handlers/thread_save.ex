defmodule DianBot.Commands.Handlers.ThreadSave do
  @moduledoc """
  Handles `/thread:save` — saves a replied-to message into a new thread.

  ## Aliases

    * `/sj` — same as `/thread:save`
    * `/rd` — same as `/thread:save`

  ## Usage

      (reply to a message) /thread:save
  """

  use DianBot.Commands.Handler

  @impl true
  def cmds do
    [
      %Entry{
        type: :immediate,
        module: __MODULE__,
        command: "thread:save",
        aliases: ["sj", "rd"],
        reply_required?: true,
        usage: "/thread:save"
      }
    ]
  end

  @impl true
  def parse_args("", _extra_segments), do: {:ok, nil}
  def parse_args(_other, _extra_segments), do: {:error, "no arguments expected"}

  @impl true
  def handle(%CommandRequest{} = request, nil) do
    case Dian.Threads.save_replied_message(
           to_string(request.group_id),
           to_string(request.sender_id),
           request.reply.message_id
         ) do
      {:ok, _result} -> {:reply, "Saved ✓"}
      {:error, :duplicate} -> {:reply, "Message already being saved by another user"}
      {:error, :fetch_failed} -> {:reply, "Error: could not fetch the replied message"}
      {:error, changeset} -> {:reply, "Error: #{inspect(changeset.errors)}"}
    end
  end
end
