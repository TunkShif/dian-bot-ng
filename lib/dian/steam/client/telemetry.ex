defmodule Dian.Steam.Client.Telemetry do
  @moduledoc false

  @handler_id "req-steam-telemetry"

  def attach do
    :telemetry.attach_many(
      @handler_id,
      [
        [:req, :request, :adapter, :stop],
        [:req, :request, :adapter, :error]
      ],
      &__MODULE__.handle_event/4,
      nil
    )
  end

  def handle_event(event, measurements, metadata, _config) do
    inner = Map.get(metadata, :metadata, %{})

    if inner[:component] == :steam_client do
      duration = System.convert_time_unit(measurements.duration, :native, :millisecond)

      :telemetry.execute(
        [:dian, :steam, :client, :request],
        %{duration: duration},
        %{
          component: :steam_client,
          operation: inner[:operation],
          success: request_success?(event, metadata)
        }
      )
    end
  end

  defp request_success?([:req, :request, :adapter, :stop], %{status: status}) do
    status in 200..299
  end

  defp request_success?(_event, _metadata), do: false
end
