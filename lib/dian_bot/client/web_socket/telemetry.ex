defmodule DianBot.Client.WebSocket.Telemetry do
  @moduledoc false

  require Logger

  @handler_id "websockex-bot-telemetry"

  def attach do
    :telemetry.attach_many(
      @handler_id,
      [
        [:websockex, :connected],
        [:websockex, :disconnected]
      ],
      &__MODULE__.handle_event/4,
      nil
    )
  end

  def handle_event(event, _measurements, metadata, _config) do
    if metadata[:module] == DianBot.Client.WebSocket do
      Logger.metadata(component: "onebot_websocket")
      log_event(event, metadata)
    end
  end

  defp log_event([:websockex, :connected], metadata) do
    Logger.info("bot ws connected", endpoint: conn_endpoint(metadata[:conn]))
  end

  defp log_event([:websockex, :disconnected], metadata) do
    Logger.info("bot ws disconnected",
      event: "disconnected",
      reason: inspect(metadata[:reason]),
      attempt_number: metadata[:attempt_number]
    )
  end

  defp conn_endpoint(%{transport: transport, host: host, port: port, path: path, query: query}) do
    scheme =
      case transport do
        :ssl -> "wss"
        _ -> "ws"
      end

    query = if query, do: "?#{query}", else: ""
    "#{scheme}://#{host}:#{port}#{path}#{query}"
  end

  defp conn_endpoint(_conn), do: nil
end
