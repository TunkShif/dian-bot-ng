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
         {:ok, entry} <- state.lookup.(request.name) do
      dispatch_entry(entry, request, state)
    else
      :ignore -> :ok
      :error -> :ok
    end
  end

  defp dispatch_entry(entry, request, state) do
    with :ok <- check_mention_required(entry, request),
         :ok <- check_reply_required(entry, request),
         {:ok, args} <- entry.module.parse_args(request.raw_args) do
      dispatch_type(entry, request, args, state)
    else
      {:error, reason} -> reply_usage(state, request.group_id, entry, reason)
      :ignore -> :ok
    end
  end

  defp dispatch_type(%{type: :immediate, module: handler}, request, args, state) do
    # TODO: check throttle
    execute_immediate(handler, request, args, state)
  end

  defp dispatch_type(%{type: :batch_collect, module: workflow}, request, args, state) do
    case Batch.collect(workflow, request, args) do
      :ok -> :ok
      {:error, reason} -> state.send_msg.(:group, request.group_id, "Error: #{reason}")
    end
  end

  defp dispatch_type(%{type: :batch_flush, module: workflow}, request, _args, state) do
    case Batch.flush(workflow, request) do
      {:reply, msg} -> state.send_msg.(:group, request.group_id, msg)
      :noreply -> :ok
      {:error, :no_entries} -> state.send_msg.(:group, request.group_id, "nothing to submit")
      {:error, reason} -> state.send_msg.(:group, request.group_id, "Error: #{reason}")
    end
  end

  defp check_mention_required(entry, request) do
    if entry.mention_required? and not request.mentions_bot?, do: :ignore, else: :ok
  end

  defp check_reply_required(entry, request) do
    if entry.reply_required? and is_nil(request.reply),
      do: {:error, "a replied message is required"},
      else: :ok
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

  defp reply_usage(state, group_id, entry, reason) do
    state.send_msg.(:group, group_id, "#{entry.usage}: #{reason}")
  end
end
