defmodule Dian.AITest do
  use Dian.DataCase, async: false

  import ExUnit.CaptureLog
  alias Dian.AI
  alias Dian.Steam.PlaySession

  import Dian.SettingsFixtures
  import Dian.SteamFixtures

  setup do
    previous_config = Application.get_env(:dian, Dian.AI)

    on_exit(fn ->
      if previous_config do
        Application.put_env(:dian, Dian.AI, previous_config)
      else
        Application.delete_env(:dian, Dian.AI)
      end
    end)

    :ok
  end

  describe "enabled?/0" do
    test "returns false when the feature flag is disabled" do
      Application.put_env(:dian, Dian.AI, enabled: false, deepseek_api_key: "secret")

      refute AI.enabled?()
    end

    test "returns false when the API key is missing" do
      Application.put_env(:dian, Dian.AI, enabled: true, deepseek_api_key: nil)

      refute AI.enabled?()
    end

    test "returns true when the feature flag and API key are both present" do
      Application.put_env(:dian, Dian.AI, enabled: true, deepseek_api_key: "secret")

      assert AI.enabled?()
    end
  end

  describe "run_daily_group_summaries/1" do
    test "generates and sends a daily summary for enabled groups with play sessions" do
      Application.put_env(:dian, Dian.AI, enabled: true, deepseek_api_key: "secret")
      enabled_group_setting_fixture(group_id: "100")
      player = steam_player_fixture(%{qq_id: "20001", display_name: "Player One"})

      Repo.insert!(%PlaySession{
        qq_id: player.qq_id,
        steam_id: player.steam_id,
        app_id: "730",
        game_name: "Counter-Strike 2",
        player_display_name: "Player One",
        started_at: ~U[2026-05-09 01:00:00Z],
        ended_at: ~U[2026-05-09 02:00:00Z],
        duration_seconds: 3600,
        session_end_reason: :stopped
      })

      sent_messages = start_supervised!({Agent, fn -> [] end})

      result =
        AI.run_daily_group_summaries(
          now: ~U[2026-05-10 02:00:00Z],
          get_group_info: fn "100" -> {:ok, %{group_id: "100", group_name: "Demo Group"}} end,
          get_group_member_list: fn "100" ->
            {:ok, [%{user_id: 20001, nickname: "Demo Nick", display_name: "Demo Card"}]}
          end,
          generate_daily_group_summary: fn context ->
            assert context.group_id == "100"
            assert context.group_name == "Demo Group"
            assert context.target_date == ~D[2026-05-09]
            assert length(context.sessions) == 1
            {:ok, "daily roast"}
          end,
          send_group_message: fn group_id, message ->
            Agent.update(sent_messages, &[{group_id, message} | &1])
            {:ok, 123}
          end
        )

      assert {:ok, %{processed_group_count: 1, sent_group_count: 1, skipped_group_count: 0}} =
               result

      assert Agent.get(sent_messages, & &1) == [{"100", "daily roast"}]
    end

    test "skips the whole run when AI is disabled" do
      Application.put_env(:dian, Dian.AI, enabled: false, deepseek_api_key: nil)

      assert {:ok, %{processed_group_count: 0, sent_group_count: 0, skipped_group_count: 0}} =
               AI.run_daily_group_summaries()
    end

    test "continues when one group generation fails" do
      Application.put_env(:dian, Dian.AI, enabled: true, deepseek_api_key: "secret")
      enabled_group_setting_fixture(group_id: "100")
      enabled_group_setting_fixture(group_id: "200")

      player = steam_player_fixture(%{qq_id: "20001"})

      Repo.insert!(%PlaySession{
        qq_id: player.qq_id,
        steam_id: player.steam_id,
        app_id: "730",
        game_name: "Counter-Strike 2",
        started_at: ~U[2026-05-09 01:00:00Z],
        ended_at: ~U[2026-05-09 02:00:00Z],
        duration_seconds: 3600,
        session_end_reason: :stopped
      })

      sent_messages = start_supervised!({Agent, fn -> [] end})

      assert {:ok, %{processed_group_count: 2, sent_group_count: 1, skipped_group_count: 1}} =
               AI.run_daily_group_summaries(
                 now: ~U[2026-05-10 02:00:00Z],
                 get_group_info: fn group_id ->
                   {:ok, %{group_id: group_id, group_name: group_id}}
                 end,
                 get_group_member_list: fn
                   "100" -> {:ok, [%{user_id: 20001, nickname: "Nick", display_name: "Card"}]}
                   "200" -> {:ok, [%{user_id: 20001, nickname: "Nick", display_name: "Card"}]}
                 end,
                 generate_daily_group_summary: fn
                   %{group_id: "100"} -> {:error, :llm_down}
                   %{group_id: "200"} -> {:ok, "daily summary"}
                 end,
                 send_group_message: fn group_id, message ->
                   Agent.update(sent_messages, &[{group_id, message} | &1])
                   {:ok, 456}
                 end
               )

      assert Agent.get(sent_messages, & &1) == [{"200", "daily summary"}]
    end

    test "logs a distinct skip reason when a group has no bound steam players" do
      Application.put_env(:dian, Dian.AI, enabled: true, deepseek_api_key: "secret")
      enabled_group_setting_fixture(group_id: "100")

      log =
        capture_log([level: :info], fn ->
          assert {:ok, %{processed_group_count: 1, sent_group_count: 0, skipped_group_count: 1}} =
                   AI.run_daily_group_summaries(
                     now: ~U[2026-05-10 02:00:00Z],
                     get_group_info: fn "100" ->
                       {:ok, %{group_id: "100", group_name: "Demo Group"}}
                     end,
                     get_group_member_list: fn "100" ->
                       {:ok,
                        [%{user_id: 20001, nickname: "Demo Nick", display_name: "Demo Card"}]}
                     end
                   )
        end)

      assert log =~ "ai daily steam summary group skipped"
      assert log =~ "no_bound_steam_players"
    end

    test "logs a distinct skip reason when a group has no sessions in the target window" do
      Application.put_env(:dian, Dian.AI, enabled: true, deepseek_api_key: "secret")
      enabled_group_setting_fixture(group_id: "100")
      steam_player_fixture(%{qq_id: "20001"})

      log =
        capture_log([level: :info], fn ->
          assert {:ok, %{processed_group_count: 1, sent_group_count: 0, skipped_group_count: 1}} =
                   AI.run_daily_group_summaries(
                     now: ~U[2026-05-10 02:00:00Z],
                     get_group_info: fn "100" ->
                       {:ok, %{group_id: "100", group_name: "Demo Group"}}
                     end,
                     get_group_member_list: fn "100" ->
                       {:ok,
                        [%{user_id: 20001, nickname: "Demo Nick", display_name: "Demo Card"}]}
                     end
                   )
        end)

      assert log =~ "ai daily steam summary group skipped"
      assert log =~ "no_sessions_in_window"
    end

    test "queries the previous 04:00 to 04:00 local gaming day window" do
      Application.put_env(:dian, Dian.AI, enabled: true, deepseek_api_key: "secret")
      enabled_group_setting_fixture(group_id: "100")
      steam_player_fixture(%{qq_id: "20001"})

      sessions_range = start_supervised!({Agent, fn -> nil end})

      assert {:ok, %{processed_group_count: 1, sent_group_count: 0, skipped_group_count: 1}} =
               AI.run_daily_group_summaries(
                 now: ~U[2026-05-10 02:00:00Z],
                 get_group_info: fn "100" ->
                   {:ok, %{group_id: "100", group_name: "Demo Group"}}
                 end,
                 get_group_member_list: fn "100" ->
                   {:ok, [%{user_id: 20001, nickname: "Demo Nick", display_name: "Demo Card"}]}
                 end,
                 list_sessions_for_players: fn qq_ids, range_start, range_end ->
                   Agent.update(sessions_range, fn _ -> {qq_ids, range_start, range_end} end)
                   []
                 end
               )

      assert {["20001"], ~U[2026-05-08 20:00:00Z], ~U[2026-05-09 20:00:00Z]} =
               Agent.get(sessions_range, & &1)
    end
  end

  describe "generate_daily_group_summary/1" do
    test "builds a fact-based prompt and delegates to the AI client" do
      Application.put_env(:dian, Dian.AI, client: Dian.AI.ClientStub)

      assert {:ok, "summary text"} =
               AI.generate_daily_group_summary(%{
                 group_id: "100",
                 group_name: "Demo Group",
                 target_date: ~D[2026-05-09],
                 sessions: [],
                 player_stats: [],
                 group_stats: %{}
               })
    end
  end
end
