defmodule Dian.Steam.Client do
  alias Dian.Steam.PlayerSummary

  @endpoint "https://api.steampowered.com"

  def get_player_summary(steam_id) do
    case get_player_summaries([steam_id]) do
      {:ok, [%PlayerSummary{} = summary]} -> summary
      _ -> nil
    end
  end

  def get_player_summaries(steam_ids) when is_list(steam_ids) do
    with {:ok, response} <-
           Req.get(req(),
             url: "/ISteamUser/GetPlayerSummaries/v0002/",
             params: [steamids: Enum.join(steam_ids, ",")]
           ),
         {:ok, data} <- handle_response(response) do
      summaries = data["response"]["players"] |> Enum.map(&PlayerSummary.build/1)
      {:ok, summaries}
    end
  end

  def get_player_achievements() do
  end

  defp req do
    api_key = Application.fetch_env!(:dian, Dian.Steam.Client) |> Keyword.fetch!(:api_key)

    Req.new(
      base_url: @endpoint,
      params: [key: api_key],
      headers: [
        {"content-type", "application/json"}
      ]
    )
  end

  defp handle_response(%Req.Response{status: status, body: body}) when status == 200 do
    {:ok, body}
  end

  # TODO: add logging, error hanlding
  # TODO: Add more cases when encountering errors
  defp handle_response(_response) do
    {:error, :request_error}
  end
end
