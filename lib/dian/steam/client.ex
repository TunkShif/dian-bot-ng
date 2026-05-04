defmodule Dian.Steam.Client do
  @type result(data) :: {:ok, data} | {:error, term()}

  @callback get_player_summary(String.t()) :: Dian.Steam.PlayerSummary.t() | nil
  @callback get_player_summaries([String.t()]) :: result([Dian.Steam.PlayerSummary.t()])

  def get_player_summary(steam_id) do
    impl().get_player_summary(steam_id)
  end

  def get_player_summaries(steam_ids) when is_list(steam_ids) do
    impl().get_player_summaries(steam_ids)
  end

  def impl do
    Application.fetch_env!(:dian, Dian.Steam)
    |> Keyword.get(:client, Dian.Steam.Client.Default)
  end
end
