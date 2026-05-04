defmodule Dian.Steam.Client.Default do
  @behaviour Dian.Steam.Client

  require Logger

  alias Dian.Steam.PlayerSummary

  @endpoint "https://api.steampowered.com"
  @env_key Dian.Steam.Client

  @impl true
  def get_player_summary(steam_id) do
    case get_player_summaries([steam_id]) do
      {:ok, [%PlayerSummary{} = summary]} -> summary
      _ -> nil
    end
  end

  @impl true
  def get_player_summaries(steam_ids) when is_list(steam_ids) do
    result =
      with {:ok, response} <-
             Req.get(req(),
               url: "/ISteamUser/GetPlayerSummaries/v0002/",
               params: [steamids: Enum.join(steam_ids, ",")],
               telemetry: [
                 metadata: %{operation: :get_player_summaries, steam_ids_count: length(steam_ids)}
               ]
             ),
           {:ok, data} <- handle_response(response) do
        summaries = data["response"]["players"] |> Enum.map(&PlayerSummary.build/1)
        {:ok, summaries}
      end

    case result do
      {:error, reason} ->
        Logger.warning("steam api request failed",
          event: "request_failed",
          operation: :get_player_summaries,
          error: reason,
          steam_ids_count: length(steam_ids)
        )

      _ ->
        :ok
    end

    result
  end

  def get_player_achievements do
    # TODO: Implement primitive Steam achievements API call when needed.
  end

  defp req do
    api_key = Application.fetch_env!(:dian, @env_key) |> Keyword.fetch!(:api_key)
    req_options = Application.get_env(:dian, __MODULE__, []) |> Keyword.get(:req_options, [])

    [
      base_url: @endpoint,
      params: [key: api_key],
      retry: false,
      headers: [
        {"content-type", "application/json"}
      ]
    ]
    |> Keyword.merge(req_options)
    |> Req.new()
    |> ReqTelemetry.attach(metadata: %{component: :steam_client})
  end

  defp handle_response(%Req.Response{status: status, body: body}) when status == 200 do
    {:ok, body}
  end

  defp handle_response(_response) do
    {:error, :request_error}
  end
end
