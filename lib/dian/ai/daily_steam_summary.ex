defmodule Dian.AI.DailySteamSummary do
  @moduledoc """
  Builds prompts and generates AI daily Steam summaries.
  """

  def generate(group_context) when is_map(group_context) do
    messages = build_messages(group_context)
    client().generate_text(messages)
  end

  def build_messages(group_context) do
    [
      {:system,
       """
       You write concise daily Steam play summaries for chat groups.
       Be playful and lightly teasing, never cruel.
       Stay grounded in the provided facts.
       Do not invent players, games, or durations.
       If the data is sparse, prefer a mild summary over forced jokes.
       Return one final message in 3 to 6 short lines or compact paragraphs.
       """},
      {:user, Jason.encode!(group_context)}
    ]
  end

  defp client do
    Application.get_env(:dian, Dian.AI, [])
    |> Keyword.get(:client, Dian.AI.Client)
  end
end
