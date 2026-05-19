defmodule DianBot.Commands.Handler do
  @moduledoc """
  Behaviour for stateless slash commands.

  Commands that should be ignored by default (unknown command names) must
  not implement this behaviour — they will never be dispatched.

  ## Optional callbacks

  `mention_required?/0` and `reply_required?/0` are optional. The dispatcher
  uses `function_exported?/3` to check before calling them. Default to `false`
  when not defined.
  """

  alias DianBot.Commands.CommandRequest

  @type reply_message :: DianBot.Message.t() | [map()] | String.t()

  @doc """
  The command name (without leading `/`), e.g. `"help"`.
  """
  @callback command() :: String.t()

  @doc """
  Alternative command names that also route to this handler.
  """
  @callback aliases() :: [String.t()]

  @doc """
  Short usage string shown to users on invalid invocation.
  """
  @callback usage() :: String.t()

  @doc """
  Whether this command requires the bot to be @-mentioned.
  """
  @callback mention_required?() :: boolean()

  @doc """
  Whether this command requires replying to another message.
  """
  @callback reply_required?() :: boolean()

  @doc """
  Parses the raw argument string into a structured argument.

  Return `{:ok, term()}` on success — the parsed value is passed to
  `handle/2`. Return `{:error, reason}` to reject with a usage reply.
  """
  @callback parse_args(String.t()) :: {:ok, term()} | {:error, String.t()}

  @doc """
  Executes the command.

  * `{:reply, message}` — sends a group reply through the dispatcher.
  * `:noreply` — silently succeeds (no group message).
  * `{:error, reason}` — sends an error reply to the group.
  """
  @callback handle(CommandRequest.t(), parsed_args :: term()) ::
            {:reply, reply_message()} | :noreply | {:error, String.t()}

  @optional_callbacks mention_required?: 0, reply_required?: 0

  @doc false
  defmacro __using__(_opts) do
    quote do
      @behaviour DianBot.Commands.Handler
    end
  end
end
