defmodule DianBot.Client.WebSocket.TelemetryTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias DianBot.Client.WebSocket.Telemetry

  test "disconnect telemetry logs status map reasons without callback field assumptions" do
    logger_level = Logger.level()
    Logger.configure(level: :info)
    on_exit(fn -> Logger.configure(level: logger_level) end)

    log =
      capture_log([level: :info], fn ->
        Telemetry.handle_event(
          [:websockex, :disconnected],
          %{time: System.system_time()},
          %{
            module: DianBot.Client.WebSocket,
            reason: {:remote, 1001, "server restart"},
            attempt_number: 2
          },
          nil
        )
      end)

    assert log =~ "bot ws disconnected"
  end
end
