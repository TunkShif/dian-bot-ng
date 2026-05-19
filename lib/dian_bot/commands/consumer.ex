defmodule DianBot.Commands.Consumer do
  @moduledoc """
  GenServer that subscribes to group-message events and dispatches
  parsed commands to registered handlers or batch workflows.

  ## Injectable options

    * `:send_msg` — function to send group replies (default `&DianBot.send_msg/3`)
    * `:subscribe?` — whether to subscribe to `DianBot.EventBus` (default `true`)
  """

  use GenServer

  require Logger

  alias DianBot.Commands.Batch
  alias DianBot.Commands.Parser
  alias DianBot.Commands.Registry
  alias DianBot.Event.GroupMessageEvent

  @doc false
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    send_msg = Keyword.get(opts, :send_msg, &DianBot.send_msg/3)
    subscribe? = Keyword.get(opts, :subscribe?, true)
    lookup = Keyword.get(opts, :lookup, &Registry.lookup/1)

    if subscribe?, do: DianBot.EventBus.subscribe()

    {:ok, %{send_msg: send_msg, lookup: lookup}}
  end

  @impl true
  def handle_info(%GroupMessageEvent{} = event, state) do
    dispatch(event, state)
    {:noreply, state}
  end

  def handle_info(_other, state), do: {:noreply, state}

  defp dispatch(event, state) do
    with {:ok, request} <- Parser.parse(event),
         {:ok, resolved} <- state.lookup.(request.name) do
      dispatch_resolved(resolved, request, state)
    else
      :ignore -> :ok
      :error -> :ok
    end
  end

  defp dispatch_resolved({:immediate, handler}, request, state) do
    with :ok <- check_mention_required(handler, request),
         :ok <- check_reply_required(handler, request),
         {:ok, args} <- handler.parse_args(request.raw_args) do
      execute_immediate(handler, request, args, state)
    else
      {:error, reason} -> reply_usage(state, request.group_id, handler, reason)
      :ignore -> :ok
    end
  end

  defp dispatch_resolved({:batch, workflow, :collect}, request, state) do
    case Batch.collect(workflow, request, request.raw_args) do
      :ok -> :ok
      {:error, reason} -> state.send_msg.(:group, request.group_id, "Error: #{reason}")
    end
  end

  defp dispatch_resolved({:batch, workflow, :flush}, request, state) do
    case Batch.flush(workflow, request) do
      {:reply, msg} -> state.send_msg.(:group, request.group_id, msg)
      :noreply -> :ok
      {:error, :no_entries} -> state.send_msg.(:group, request.group_id, "nothing to submit")
      {:error, reason} -> state.send_msg.(:group, request.group_id, "Error: #{reason}")
    end
  end

  defp check_mention_required(handler, request) do
    if function_exported?(handler, :mention_required?, 0) and
         handler.mention_required?() and
         not request.mentions_bot? do
      :ignore
    else
      :ok
    end
  end

  defp check_reply_required(handler, request) do
    if function_exported?(handler, :reply_required?, 0) and
         handler.reply_required?() and
         is_nil(request.reply) do
      {:error, "a replied message is required"}
    else
      :ok
    end
  end

  defp execute_immediate(handler, request, args, state) do
    result =
      try do
        handler.handle(request, args)
      rescue
        exception ->
          Logger.error(fn ->
            "handler crashed handler=#{inspect(handler)} command=#{request.name} error=#{Exception.message(exception)}"
          end)

          {:error, "command failed"}
      end

    case result do
      {:reply, msg} -> state.send_msg.(:group, request.group_id, msg)
      :noreply -> :ok
      {:error, reason} -> state.send_msg.(:group, request.group_id, "Error: #{reason}")
    end
  end

  defp reply_usage(state, group_id, handler, reason) do
    state.send_msg.(:group, group_id, "#{handler.usage()}: #{reason}")
  end
end
