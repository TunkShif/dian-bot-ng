defmodule Dian.AI do
  @moduledoc """
  Coordinates AI-generated daily Steam summaries for enabled groups.
  """

  alias Dian.AI.DailySteamSummary

  def enabled? do
    config = config()

    config[:enabled] == true and present?(config[:deepseek_api_key])
  end

  def run_daily_group_summaries(opts \\ []) do
    if enabled?() do
      DailySteamSummary.Runner.run(opts)
    else
      {:ok, %{processed_group_count: 0, sent_group_count: 0, skipped_group_count: 0}}
    end
  end

  def generate_daily_group_summary(group_context) when is_map(group_context) do
    DailySteamSummary.generate(group_context)
  end

  defp present?(value) when is_binary(value), do: String.trim(value) != ""
  defp present?(_), do: false

  defp config do
    Application.get_env(:dian, Dian.AI, [])
  end
end
