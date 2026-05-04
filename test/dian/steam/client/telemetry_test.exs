defmodule Dian.Steam.Client.TelemetryTest do
  use ExUnit.Case, async: true

  alias Dian.Steam.Client.Telemetry

  test "maps non-2xx adapter stops to unsuccessful Steam requests" do
    ref = attach_test_handler([:dian, :steam, :client, :request])

    Telemetry.handle_event(
      [:req, :request, :adapter, :stop],
      %{duration: System.convert_time_unit(125, :millisecond, :native)},
      %{
        status: 500,
        metadata: %{component: :steam_client, operation: :get_player_summaries}
      },
      nil
    )

    assert_receive {^ref, %{duration: 125}, metadata}
    assert metadata.success == false
    assert metadata.operation == :get_player_summaries
  end

  test "maps adapter errors to unsuccessful Steam requests" do
    ref = attach_test_handler([:dian, :steam, :client, :request])

    Telemetry.handle_event(
      [:req, :request, :adapter, :error],
      %{duration: System.convert_time_unit(50, :millisecond, :native)},
      %{
        error: :timeout,
        metadata: %{component: :steam_client, operation: :get_player_summaries}
      },
      nil
    )

    assert_receive {^ref, %{duration: 50}, metadata}
    assert metadata.success == false
  end

  defp attach_test_handler(event) do
    parent = self()
    ref = make_ref()
    handler_id = {__MODULE__, ref}

    :telemetry.attach(
      handler_id,
      event,
      fn _event, measurements, metadata, _config ->
        send(parent, {ref, measurements, metadata})
      end,
      nil
    )

    on_exit(fn -> :telemetry.detach(handler_id) end)

    ref
  end
end
