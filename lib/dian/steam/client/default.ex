defmodule Dian.Steam.Client.Default do
  @behaviour Dian.Steam.Client

  require Logger

  alias Dian.Steam.GameSchema
  alias Dian.Steam.PlayerAchievement
  alias Dian.Steam.PlayerSummary

  @endpoint "https://api.steampowered.com"
  @steam_env_key Dian.Steam
  @client_env_key __MODULE__

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

  @impl true
  def get_player_achievements(steam_id, app_id, locale \\ :en) do
    with {:ok, response} <-
           Req.get(req(),
             url: "/ISteamUserStats/GetPlayerAchievements/v0001/",
             params: [steamid: steam_id, appid: app_id, l: steam_locale(locale)],
             telemetry: [
               metadata: %{
                 operation: :get_player_achievements,
                 steam_id: steam_id,
                 app_id: app_id
               }
             ]
           ),
         {:ok, data} <- handle_response(response) do
      handle_player_achievements_response(data)
    end
    |> log_error(:get_player_achievements, %{steam_id: steam_id, app_id: app_id})
  end

  @impl true
  def get_game_schema(app_id, locale \\ :en) do
    with {:ok, response} <-
           Req.get(req(),
             url: "/ISteamUserStats/GetSchemaForGame/v0002/",
             params: [appid: app_id, format: "json", l: steam_locale(locale)],
             telemetry: [metadata: %{operation: :get_game_schema, app_id: app_id}]
           ),
         {:ok, data} <- handle_response(response),
         %{"game" => game} when is_map(game) <- data do
      {:ok, GameSchema.build(app_id, game)}
    else
      %{} -> {:error, :request_error}
      {:error, reason} -> {:error, reason}
    end
    |> log_error(:get_game_schema, %{app_id: app_id})
  end

  defp req do
    api_key = Application.fetch_env!(:dian, @steam_env_key) |> Keyword.fetch!(:api_key)
    req_options = Application.get_env(:dian, @client_env_key, []) |> Keyword.get(:req_options, [])

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

  defp handle_player_achievements_response(%{"playerstats" => %{"success" => true} = stats}) do
    achievements = stats["achievements"] || []
    {:ok, Enum.map(achievements, &PlayerAchievement.build/1)}
  end

  defp handle_player_achievements_response(%{
         "playerstats" => %{"success" => false, "error" => "Requested app has no stats"}
       }) do
    {:error, :no_stats}
  end

  defp handle_player_achievements_response(_data), do: {:error, :request_error}

  defp steam_locale(:zh), do: "schinese"
  defp steam_locale(:en), do: "english"
  defp steam_locale(locale) when is_atom(locale), do: Atom.to_string(locale)

  defp log_error({:error, reason} = result, operation, metadata) do
    Logger.warning("steam api request failed",
      event: "request_failed",
      operation: operation,
      error: reason,
      metadata: inspect(metadata)
    )

    result
  end

  defp log_error(result, _operation, _metadata), do: result
end
