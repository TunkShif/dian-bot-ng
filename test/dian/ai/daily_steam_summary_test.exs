defmodule Dian.AI.DailySteamSummaryTest do
  use ExUnit.Case, async: true

  alias Dian.AI.DailySteamSummary
  alias Dian.AI.DailySteamSummary.ContextBuilder

  setup do
    previous_locale = Application.get_env(:dian, :notification_locale)

    on_exit(fn ->
      if previous_locale do
        Application.put_env(:dian, :notification_locale, previous_locale)
      else
        Application.delete_env(:dian, :notification_locale)
      end
    end)

    :ok
  end

  test "build_messages/1 encodes the provided group context as JSON user input" do
    Application.put_env(:dian, :notification_locale, :en)

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
    assert system_prompt =~ "Write the final output in English."
    assert system_prompt =~ "Return plain text and emojis only and do not use Markdown syntax."
    assert user_payload =~ "\"group_id\":\"100\""
    assert user_payload =~ "\"display_name\":\"Card\""
  end

  test "build_messages/1 uses the configured chinese notification locale" do
    Application.put_env(:dian, :notification_locale, :zh)

    [{:system, system_prompt}, {:user, _user_payload}] =
      DailySteamSummary.build_messages(%{
        group_id: "100",
        group_name: "Demo Group",
        target_date: ~D[2026-05-09],
        members: [],
        sessions: [],
        player_stats: [],
        group_stats: %{}
      })

    assert system_prompt =~ "Write the final output in Simplified Chinese."
    assert system_prompt =~ "The target IM platform does not render Markdown."
  end

  test "context builder rewrites session player names to group display names" do
    context =
      ContextBuilder.build(
        %{group_id: "100", group_name: "Demo Group"},
        [%{user_id: 20001, display_name: "Group Card", nickname: "Nick"}],
        [
          %{
            qq_id: "20001",
            steam_id: "76561198000000001",
            app_id: "730",
            game_name: "Counter-Strike 2",
            player_display_name: "Steam Persona",
            started_at: ~U[2026-05-08 16:00:00Z],
            ended_at: ~U[2026-05-08 17:00:00Z],
            duration_seconds: 3600,
            session_end_reason: :stopped
          }
        ],
        ~D[2026-05-09]
      )

    assert [%{player_display_name: "Group Card"}] = context.sessions
    assert [%{display_name: "Group Card"}] = context.player_stats
  end
end
