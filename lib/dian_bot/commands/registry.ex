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
    defstruct [
      :type,
      :module,
      :command,
      :aliases,
      :usage,
      :throttle,
      mention_required?: false,
      reply_required?: false
    ]

    @type t :: %__MODULE__{
            type: :immediate | :batch_collect | :batch_flush,
            module: module(),
            command: String.t(),
            aliases: [String.t()],
            mention_required?: boolean(),
            reply_required?: boolean(),
            usage: String.t(),
            throttle: DianBot.Commands.Throttle.Policy.t() | nil
          }
  end

  @handlers [
    DianBot.Commands.Handlers.Ping,
    DianBot.Commands.Handlers.Weather,
    DianBot.Commands.Handlers.Note
  ]

  @entries for mod <- @handlers,
               entry <- mod.cmds(),
               name <- [entry.command | entry.aliases],
               into: %{},
               do: {name, entry}

  @doc """
  Looks up a command name in the registry.

  Returns `{:ok, %Entry{}}` or `:error` when the name is unknown.
  """
  @spec lookup(String.t()) :: {:ok, Entry.t()} | :error
  def lookup(name) when is_binary(name) do
    case Map.get(entries(), name) do
      nil -> :error
      entry -> {:ok, entry}
    end
  end

  @doc """
  Returns all registered commands as `{name, type, module}` tuples.
  """
  @spec commands() :: [{String.t(), :immediate | :batch_collect | :batch_flush, module()}]
  def commands do
    for {name, entry} <- entries(), do: {name, entry.type, entry.module}
  end

  defp entries do
    @entries
  end
end
