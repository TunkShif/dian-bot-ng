defmodule Dian.Steam.Client do
  @type result(data) :: {:ok, data} | {:error, term()}

  @callback get_player_summary(String.t()) :: Dian.Steam.PlayerSummary.t() | nil
  @callback get_player_summaries([String.t()]) :: result([Dian.Steam.PlayerSummary.t()])
  @callback get_player_achievements(String.t(), String.t(), atom()) ::
              result([Dian.Steam.PlayerAchievement.t()])
  @callback get_game_schema(String.t(), atom()) :: result(Dian.Steam.GameSchema.t())

  def get_player_summary(steam_id) do
    impl().get_player_summary(steam_id)
  end

  def get_player_summaries(steam_ids) when is_list(steam_ids) do
    impl().get_player_summaries(steam_ids)
  end

  def get_player_achievements(steam_id, app_id, locale \\ :en)
      when is_binary(steam_id) and is_binary(app_id) and is_atom(locale) do
    impl().get_player_achievements(steam_id, app_id, locale)
  end

  def get_game_schema(app_id, locale \\ :en) when is_binary(app_id) and is_atom(locale) do
    impl().get_game_schema(app_id, locale)
  end

  def impl do
    Application.fetch_env!(:dian, Dian.Steam)
    |> Keyword.get(:client, Dian.Steam.Client.Default)
  end
end
