defmodule DianBot.Client.WebSocket.Transport do
  use WebSockex

  require Logger

  def start_link(opts) do
    endpoint = Keyword.fetch!(opts, :endpoint)
    access_token = Keyword.fetch!(opts, :access_token)

    state = %{
      broker_pid: nil,
      endpoint: endpoint,
      access_token: access_token
    }

    WebSockex.start_link(endpoint, __MODULE__, state,
      name: __MODULE__,
      async: true,
      handle_initial_conn_failure: true,
      extra_headers: [{"Authorization", "Bearer #{access_token}"}]
    )
  end

  @impl true
  def handle_connect(_conn, state) do
    if pid = Process.whereis(DianBot.Client.WebSocket) do
      send(pid, {:ws_connected, self()})
      {:ok, %{state | broker_pid: pid}}
    else
      {:ok, state}
    end
  end

  @impl true
  def handle_disconnect(%{reason: reason, attempt_number: attempt}, state) do
    if pid = state.broker_pid do
      send(pid, {:ws_disconnected, reason})
    end

    Logger.warning("bot ws disconnected",
      event: "disconnected",
      reason: inspect(reason),
      attempt_number: attempt
    )

    backoff = min(attempt * 1_000, 30_000)
    Process.send_after(self(), :reconnect, backoff)
    {:ok, state}
  end

  @impl true
  def handle_info(:reconnect, state) do
    {:reconnect, state}
  end

  @impl true
  def handle_frame({:text, msg}, state) do
    case Jason.decode(msg) do
      {:ok, payload} ->
        if pid = state.broker_pid do
          send(pid, {:ws_payload, payload})
        end

        {:ok, state}

      {:error, reason} ->
        Logger.warning("invalid ws payload dropped",
          event: "invalid_payload",
          error: Exception.message(reason)
        )

        {:ok, state}
    end
  end

  def handle_frame({:binary, _data}, state) do
    Logger.warning("unsupported binary frame dropped",
      event: "binary_frame_dropped"
    )

    {:ok, state}
  end

  @impl true
  def handle_cast({:send_frame, payload}, state) do
    {:reply, {:text, Jason.encode!(payload)}, state}
  end
end
