defmodule DianBot.Commands.Handler do
  @moduledoc """
  Behaviour for stateless slash commands.

  Commands that should be ignored by default (unknown command names) must
  not implement this behaviour — they will never be dispatched.
  """

  alias DianBot.Commands.CommandRequest
  alias DianBot.Commands.Registry.Entry

  @type reply_message :: DianBot.Message.t() | [map()] | String.t()

  @doc """
  Returns the registry entries describing the commands handled by this module.

  Each entry declares the command name, aliases, type, usage string, and
  dispatch options. The Registry collects these at compile time to build
  the name-to-entry lookup map.
  """
  @callback cmds() :: [Entry.t()]

  @doc """
  Parses arguments into a structured argument.

  Receives the raw argument string (everything after the command name within
  the command text segment) and any extra segments that follow the command
  text (e.g. @-mentions of other users).

  Return `{:ok, term()}` on success — the parsed value is passed to
  `handle/2`. Return `{:error, reason}` to reject with a usage reply.
  """
  @callback parse_args(String.t(), [map()]) :: {:ok, term()} | {:error, String.t()}

  @doc """
  Executes the command.

  * `{:reply, message}` — sends a group reply through the dispatcher.
  * `:noreply` — silently succeeds (no group message).
  * `{:error, reason}` — sends an error reply to the group.
  """
  @callback handle(CommandRequest.t(), parsed_args :: term()) ::
              {:reply, reply_message()} | :noreply | {:error, String.t()}

  @doc false
  defmacro __using__(_opts) do
    quote do
      @behaviour DianBot.Commands.Handler
      alias DianBot.Commands.CommandRequest
      alias DianBot.Commands.Registry.Entry
      alias DianBot.Commands.Throttle.Policy
    end
  end
end
