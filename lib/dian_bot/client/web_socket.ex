defmodule DianBot.Client.WebSocket do
  use GenServer

  require Logger

  alias DianBot.Event
  alias DianBot.EventBus
  alias DianBot.OneBot

  @behaviour DianBot.Client

  @default_timeout 5_000

  # Public API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def request(action, params, opts) when is_list(opts) do
    GenServer.call(__MODULE__, {:request, action, params, opts}, :infinity)
  end

  # GenServer callbacks

  @impl true
  def init(opts) do
    timeout = Keyword.get(opts, :timeout, @default_timeout)

    state = %{
      timeout: timeout,
      transport_pid: nil,
      connected?: false,
      pending: %{},
      monitors: %{}
    }

    {:ok, state}
  end

  @impl true
  def handle_call({:request, action, params, opts}, from, state) do
    if !state.connected? or state.transport_pid == nil do
      {:reply, {:error, :disconnected}, state}
    else
      echo = Ecto.UUID.generate()
      caller_pid = elem(from, 0)
      monitor = Process.monitor(caller_pid)
      per_request_timeout = Keyword.get(opts, :timeout, state.timeout)
      timer = Process.send_after(self(), {:request_timeout, echo}, per_request_timeout)
      started_at = System.monotonic_time(:millisecond)

      pending_req = %{
        from: from,
        caller_pid: caller_pid,
        action: action,
        timer: timer,
        monitor: monitor,
        started_at: started_at
      }

      payload = OneBot.build_request(echo, action, params)

      state = put_in(state.pending[echo], pending_req)
      state = put_in(state.monitors[monitor], echo)

      WebSockex.cast(state.transport_pid, {:send_frame, payload})

      {:noreply, state}
    end
  end

  @impl true
  def handle_info({:ws_connected, transport_pid}, state) do
    {:noreply, %{state | transport_pid: transport_pid, connected?: true}}
  end

  def handle_info({:ws_disconnected, _reason}, state) do
    pending = state.pending

    state = %{state | connected?: false, transport_pid: nil, pending: %{}, monitors: %{}}

    for {_echo, req} <- pending do
      Process.demonitor(req.monitor, [:flush])
      Process.cancel_timer(req.timer)

      GenServer.reply(req.from, {:error, :disconnected})

      :telemetry.execute(
        [:dian, :bot, :websocket, :request],
        %{duration: System.monotonic_time(:millisecond) - req.started_at},
        %{
          component: :onebot_websocket,
          bot_action: req.action,
          success: false,
          outcome: :disconnected
        }
      )
    end

    if pending != %{} do
      Logger.warning("bot ws disconnected, drained #{map_size(pending)} pending requests",
        event: "drain_pending_on_disconnect",
        count: map_size(pending)
      )
    end

    {:noreply, state}
  end

  def handle_info({:ws_payload, payload}, state) do
    payload_class = OneBot.classify_payload(payload)

    :telemetry.execute(
      [:dian, :bot, :websocket, :message],
      %{count: 1},
      %{component: :onebot_websocket, payload_class: payload_class}
    )

    case payload_class do
      :event -> handle_event(payload, state)
      :response -> handle_response(payload, state)
      :ignored -> handle_ignored(payload, state)
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    case state.monitors do
      %{^ref => echo} ->
        case state.pending do
          %{^echo => req} ->
            state = delete_pending(state, echo, req)
            {:noreply, state}

          _ ->
            {:noreply, state}
        end

      _ ->
        {:noreply, state}
    end
  end

  def handle_info({:request_timeout, echo}, state) do
    case state.pending do
      %{^echo => req} ->
        state = delete_pending(state, echo, req)

        GenServer.reply(req.from, {:error, :timeout})

        :telemetry.execute(
          [:dian, :bot, :websocket, :request],
          %{duration: System.monotonic_time(:millisecond) - req.started_at},
          %{
            component: :onebot_websocket,
            bot_action: req.action,
            success: false,
            outcome: :timeout
          }
        )

        {:noreply, state}

      _ ->
        {:noreply, state}
    end
  end

  # Private helpers

  defp handle_event(payload, state) do
    if event = Event.build(payload) do
      EventBus.broadcast(event)
    end

    {:noreply, state}
  end

  defp handle_response(payload, state) do
    echo = Map.fetch!(payload, "echo")

    case state.pending do
      %{^echo => req} ->
        state = delete_pending(state, echo, req)

        GenServer.reply(req.from, OneBot.response_result(payload))

        :telemetry.execute(
          [:dian, :bot, :websocket, :request],
          %{duration: System.monotonic_time(:millisecond) - req.started_at},
          %{
            component: :onebot_websocket,
            bot_action: req.action,
            success: true,
            outcome: :ok
          }
        )

        {:noreply, state}

      _ ->
        Logger.warning("late or unknown response dropped",
          event: "late_response",
          echo: echo
        )

        {:noreply, state}
    end
  end

  defp handle_ignored(payload, state) do
    Logger.debug("ws message ignored",
      event: "message_ignored",
      has_echo: Map.has_key?(payload, "echo"),
      post_type: payload["post_type"],
      message_type: payload["message_type"]
    )

    {:noreply, state}
  end

  defp delete_pending(state, echo, req) do
    Process.demonitor(req.monitor, [:flush])
    Process.cancel_timer(req.timer)

    %{
      state
      | pending: Map.delete(state.pending, echo),
        monitors: Map.delete(state.monitors, req.monitor)
    }
  end
end
