defmodule Dian.AI.DailySteamSummaryTest do
  use ExUnit.Case, async: true

  alias Dian.AI.DailySteamSummary

  test "build_messages/1 encodes the provided group context as JSON user input" do
    messages =
      DailySteamSummary.build_messages(%{
        group_id: "100",
        group_name: "Demo Group",
        target_date: ~D[2026-05-09],
        members: [%{user_id: "20001", display_name: "Card", nickname: "Nick"}],
        sessions: [],
        player_stats: [],
        group_stats: %{total_playtime_seconds: 3600}
      })

    assert [{:system, system_prompt}, {:user, user_payload}] = messages
    assert system_prompt =~ "Be playful and lightly teasing"
    assert user_payload =~ "\"group_id\":\"100\""
    assert user_payload =~ "\"display_name\":\"Card\""
  end
end
