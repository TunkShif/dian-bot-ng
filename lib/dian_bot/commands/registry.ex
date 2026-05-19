defmodule DianBot.Commands.Registry do
  @moduledoc """
  Maps command names and aliases to handler or batch-workflow modules.

  The command table is static (module attribute). Entries are `%Entry{}`
  structs with a `type` field that determines how the consumer dispatches.
  """

  defmodule Entry do
    @moduledoc """
    A registry entry describing a single command with its type, module, and
    generic dispatch options (`mention_required?`, `reply_required?`, `usage`,
    `throttle`).
    """
    defstruct [:type, :module, :mention_required?, :reply_required?, :usage, :throttle]

    @type t :: %__MODULE__{
            type: :immediate | :batch_collect | :batch_flush,
            module: module(),
            mention_required?: boolean(),
            reply_required?: boolean(),
            usage: String.t(),
            throttle: term()
          }
  end

  @entries %{}

  @doc """
  Looks up a command name in the registry.

  Returns `{:ok, %Entry{}}` or `:error` when the name is unknown.
  """
  @spec lookup(String.t()) :: {:ok, Entry.t()} | :error
  def lookup(name) when is_binary(name) do
    case Map.get(@entries, name) do
      nil -> :error
      entry -> {:ok, entry}
    end
  end

  @doc """
  Returns all registered commands as `{name, type, module}` tuples.
  """
  @spec commands() :: [{String.t(), :immediate | :batch_collect | :batch_flush, module()}]
  def commands do
    for {name, entry} <- @entries, do: {name, entry.type, entry.module}
  end
end
