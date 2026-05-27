defmodule DianBot.Client.WebSocket do
  use WebSockex

  require Logger

  alias DianBot.Event
  alias DianBot.EventBus
  alias DianBot.OneBot

  @behaviour DianBot.Client

  @env_key DianBot.Bot
  @default_timeout 5_000

  def start_link(_opts) do
    config = Application.fetch_env!(:dian, @env_key)

    initial_state = %{pending: %{}}
    endpoint = Keyword.fetch!(config, :endpoint)
    access_token = Keyword.fetch!(config, :access_token)
    extra_headers = [{"Authorization", "Bearer #{access_token}"}]

    WebSockex.start_link(endpoint, __MODULE__, initial_state,
      name: __MODULE__,
      extra_headers: extra_headers
    )
  end

  defp cast(message) do
    WebSockex.cast(__MODULE__, message)
  end

  @impl true
  def request(action, params, opts) when is_list(opts) do
    timeout = Keyword.get(opts, :timeout, default_timeout())

    ref = make_ref()
    request_id = Ecto.UUID.generate()
    start_time = System.monotonic_time(:millisecond)
    cast({:request, {self(), ref}, request_id, action, params})

    {result, metadata} =
      receive do
        {:response, ^ref, result} ->
          {result, %{success: true}}
      after
        timeout ->
          Logger.warning("bot request timed out",
            event: "request_timeout",
            bot_action: action,
            timeout_ms: timeout
          )

          cast({:cancel_request, request_id, ref})
          {{:error, :timeout}, %{success: false}}
      end

    :telemetry.execute(
      [:dian, :bot, :websocket, :request],
      %{duration: System.monotonic_time(:millisecond) - start_time},
      Map.merge(metadata, %{
        component: :onebot_websocket,
        bot_action: action
      })
    )

    result
  end

  @impl true
  def handle_frame({:text, msg}, state) do
    with {:ok, payload} <- Jason.decode(msg) do
      handle_message(payload, state)
    else
      {:error, reason} ->
        Logger.warning("invalid ws payload dropped",
          event: "invalid_payload",
          error: Exception.message(reason)
        )

        {:ok, state}
    end
  end

  @impl true
  def handle_cast({:request, caller, request_id, action, params}, state) do
    payload = OneBot.build_request(request_id, action, params)

    new_state = put_in(state.pending[request_id], caller)

    {:reply, {:text, Jason.encode!(payload)}, new_state}
  end

  def handle_cast({:cancel_request, echo, ref}, state) do
    pending =
      case Map.get(state.pending, echo) do
        {_pid, ^ref} -> Map.delete(state.pending, echo)
        _ -> state.pending
      end

    {:ok, %{state | pending: pending}}
  end

  defp handle_message(payload, state) do
    payload_class = OneBot.classify_payload(payload)

    :telemetry.execute(
      [:dian, :bot, :websocket, :message],
      %{count: 1},
      %{
        component: :onebot_websocket,
        payload_class: payload_class
      }
    )

    case payload_class do
      :event -> handle_event(payload, state)
      :response -> handle_response(payload, state)
      :ignored -> handle_ignored(payload, state)
    end
  end

  defp handle_event(payload, state) do
    if event = Event.build(payload) do
      EventBus.broadcast(event)
    end

    {:ok, state}
  end

  defp handle_response(payload, state) do
    request_id = Map.fetch!(payload, "echo")
    {caller, pending} = Map.pop(state.pending, request_id)

    case caller do
      nil ->
        {:ok, state}

      {pid, ref} ->
        send(pid, {:response, ref, OneBot.response_result(payload)})
        {:ok, %{state | pending: pending}}
    end
  end

  defp handle_ignored(payload, state) do
    Logger.debug("ws message ignored",
      event: "message_ignored",
      has_echo: Map.has_key?(payload, "echo"),
      post_type: payload["post_type"],
      message_type: payload["message_type"]
    )

    {:ok, state}
  end

  @impl true
  def handle_disconnect(_conn, state) do
    Logger.warning("bot websocket disconnected, notifying pending callers",
      event: "ws_disconnected",
      pending_count: map_size(state.pending)
    )

    # Notify all pending callers so they don't hang until timeout.
    Enum.each(state.pending, fn {_request_id, {pid, ref}} ->
      send(pid, {:response, ref, {:error, :disconnected}})
    end)

    {:ok, %{state | pending: %{}}}
  end

  defp default_timeout() do
    Application.fetch_env!(:dian, @env_key)
    |> Keyword.get(:timeout, @default_timeout)
  end
end
