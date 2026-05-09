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
      {:system, system_prompt()},
      {:user, Jason.encode!(group_context)}
    ]
  end

  defp system_prompt do
    """
    You write concise daily Steam play summaries for chat groups.
    #{output_language_instruction(notification_locale())}
    Be playful and lightly teasing, never cruel.
    Stay grounded in the provided facts.
    Do not invent players, games, or durations.
    If the data is sparse, prefer a mild summary over forced jokes.
    The target IM platform does not render Markdown.
    Return plain text and emojis only and do not use Markdown syntax.
    Return one final message in 3 to 6 short lines or compact paragraphs.
    """
  end

  defp output_language_instruction(:zh), do: "Write the final output in Simplified Chinese."
  defp output_language_instruction(_locale), do: "Write the final output in English."

  defp notification_locale do
    Application.get_env(:dian, :notification_locale, :zh)
  end

  defp client do
    Application.get_env(:dian, Dian.AI, [])
    |> Keyword.get(:client, Dian.AI.Client)
  end
end
