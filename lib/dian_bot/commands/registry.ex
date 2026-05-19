defmodule DianBot.Commands.Registry do
  @moduledoc """
  Maps command names and aliases to handler or batch-workflow modules.

  The command table is static (module attributes). Two categories:

    * `:immediate` — stateless commands backed by `DianBot.Commands.Handler`
    * `:batch` — accumulator commands backed by `DianBot.Commands.BatchWorkflow`
  """

  @immediate %{}
  @batch %{}

  @doc """
  Looks up a command name in the registry.

  Returns `{:ok, {:immediate, handler_mod}}`, `{:ok, {:batch, workflow_mod, action}}`,
  or `:error` when the name is unknown.
  """
  @spec lookup(String.t()) ::
          {:ok, {:immediate, module()}}
          | {:ok, {:batch, module(), :collect | :flush}}
          | :error
  def lookup(name) when is_binary(name) do
    case Map.get(immediate(), name) do
      {type, mod, action} when type == :batch ->
        {:ok, {:batch, mod, action}}

      mod when not is_nil(mod) ->
        {:ok, {:immediate, mod}}

      nil ->
        case Map.get(batch(), name) do
          {mod, action} -> {:ok, {:batch, mod, action}}
          nil -> :error
        end
    end
  end

  @doc """
  Returns all registered commands as `{name, type, module}` tuples.
  """
  @spec commands() :: [{String.t(), :immediate | :batch, module()}]
  def commands do
    immediates = for {name, mod} <- @immediate, do: {name, :immediate, mod}
    batches = for {name, {mod, _action}} <- @batch, do: {name, :batch, mod}
    immediates ++ batches
  end

  defp immediate do
    @immediate
  end

  defp batch do
    @batch
  end
end
