defmodule DianBot.Commands.BatchWorkflow do
  @moduledoc """
  Behaviour for batch workflow commands.

  A batch workflow accumulates entries from multiple command invocations
  (e.g. `/append key`) and flushes them — either via a manual `/submit`
  or automatically after `timeout_ms/0` of inactivity.

  ## Lifecycle

  1. `scope/1` extracts the grouping key from a command request (typically
     `%{group_id: ..., sender_id: ...}`).
  2. `collect/2` validates the request and returns the entry to be stored.
  3. `flush/3` receives all accumulated entries (grouped or raw) and
     performs the deferred work.
  """

  alias DianBot.Commands.CommandRequest
  alias DianBot.Commands.Registry.Entry

  @type reply_message :: DianBot.Message.t() | [map()] | String.t()

  @doc """
  Returns the registry entries describing the commands handled by this module.

  Batch workflows typically return two entries — one `:batch_collect` and one
  `:batch_flush` — both pointing to the same workflow module.
  """
  @callback cmds() :: [Entry.t()]

  @doc """
  A unique atom identifying this workflow, used for session keying in the
  batch GenServer.
  """
  @callback workflow() :: atom()

  @doc """
  Inactivity timeout in milliseconds. The session is auto-flushed after
  this duration without new entries.
  """
  @callback timeout_ms() :: pos_integer()

  @doc """
  Extracts the scope from a command request.

  The scope determines session isolation — requests sharing the same
  scope share the same pending session. For group user workflows:

      %{group_id: request.group_id, sender_id: request.sender_id}
  """
  @callback scope(CommandRequest.t()) :: term()

  @doc """
  Parses and validates arguments for a collect command.

  Receives the raw argument string (everything after the command name within
  the command text segment) and any extra segments that follow the command
  text (e.g. @-mentions of other users).

  For flush commands (which take no arguments), extra segments can be ignored.

  Return `{:ok, parsed_args}` on success or `{:error, reason}` to reject.
  """
  @callback parse_args(String.t(), [map()]) :: {:ok, term()} | {:error, String.t()}

  @doc """
  Validates and converts a command request into a stored entry.

  Called when a user sends a collect command (e.g. `/append key`).
  Returns `{:ok, entry}` to store the entry, or `{:error, reason}`
  to reject with a usage reply.
  """
  @callback collect(CommandRequest.t(), parsed_args :: term()) ::
              {:ok, entry :: term()} | {:error, String.t()}

  @doc """
  Flushes all accumulated entries for a scope.

  `reason` is `:submit` for manual submission or `:timeout` for
  auto-flush after inactivity.

  * `{:reply, message}` — sends a group reply.
  * `:noreply` — silently succeeds.
  * `{:error, reason}` — on timeout failures the error is only logged,
    not sent to the group.
  """
  @callback flush(scope :: term(), entries :: [term()], reason :: :submit | :timeout) ::
              {:reply, reply_message()} | :noreply | {:error, String.t()}

  @doc false
  defmacro __using__(_opts) do
    quote do
      @behaviour DianBot.Commands.BatchWorkflow
      alias DianBot.Commands.CommandRequest
      alias DianBot.Commands.Registry.Entry
      alias DianBot.Commands.Throttle.Policy
    end
  end
end
