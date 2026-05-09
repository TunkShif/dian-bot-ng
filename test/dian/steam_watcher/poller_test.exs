defmodule Dian.SteamWatcher.PollerTest do
  use Dian.DataCase

  alias Dian.Steam
  alias Dian.Steam.PlayerSummary
  alias Dian.SteamWatcher.StatusChanged
  alias Dian.SteamWatcher.StatusPoller

  import Dian.SteamFixtures

  describe "check_now/1" do
    test "uses the first poll as a baseline without broadcasting status changes" do
      steam_player_fixture()

      poller =
        start_supervised!(
          {StatusPoller,
           name: nil,
           interval: false,
           fetch_summaries: fn [steam_id] ->
             {:ok, [%PlayerSummary{steam_id: steam_id, playing_game_id: nil}]}
           end}
        )

      StatusPoller.subscribe()

      assert {:ok, []} = StatusPoller.check_now(poller)
      refute_receive %StatusChanged{steam_id: _steam_id}
    end

    test "broadcasts when a bound player starts playing a game after the baseline poll" do
      player = steam_player_fixture()

      summaries =
        start_supervised!({Agent, fn -> [%PlayerSummary{steam_id: player.steam_id}] end})

      poller =
        start_supervised!(
          {StatusPoller,
           name: nil,
           interval: false,
           fetch_summaries: fn [_steam_id] -> {:ok, Agent.get(summaries, & &1)} end}
        )

      StatusPoller.subscribe()

      assert {:ok, []} = StatusPoller.check_now(poller)

      Agent.update(summaries, fn _summaries ->
        [
          %PlayerSummary{
            steam_id: player.steam_id,
            playing_game_id: "730",
            playing_game_name: "Counter-Strike 2"
          }
        ]
      end)

      assert {:ok, [%StatusChanged{} = event]} = StatusPoller.check_now(poller)

      assert event.steam_id == player.steam_id
      assert event.qq_id == player.qq_id
      assert event.previous_game_id == nil
      assert event.previous_game_name == nil
      assert event.current_game_id == "730"
      assert event.current_game_name == "Counter-Strike 2"
      assert %DateTime{} = event.changed_at

      assert_receive %StatusChanged{steam_id: steam_id, current_game_id: "730"}
      assert steam_id == player.steam_id
    end

    test "broadcasts when a bound player switches games" do
      player = steam_player_fixture()

      summaries =
        start_supervised!(
          {Agent,
           fn ->
             [
               %PlayerSummary{
                 steam_id: player.steam_id,
                 playing_game_id: "730",
                 playing_game_name: "Counter-Strike 2"
               }
             ]
           end}
        )

      poller =
        start_supervised!(
          {StatusPoller,
           name: nil,
           interval: false,
           fetch_summaries: fn [_steam_id] -> {:ok, Agent.get(summaries, & &1)} end}
        )

      StatusPoller.subscribe()

      assert {:ok, []} = StatusPoller.check_now(poller)

      Agent.update(summaries, fn _summaries ->
        [
          %PlayerSummary{
            steam_id: player.steam_id,
            playing_game_id: "570",
            playing_game_name: "Dota 2"
          }
        ]
      end)

      assert {:ok, [%StatusChanged{} = event]} = StatusPoller.check_now(poller)

      assert event.previous_game_id == "730"
      assert event.previous_game_name == "Counter-Strike 2"
      assert event.current_game_id == "570"
      assert event.current_game_name == "Dota 2"

      assert_receive %StatusChanged{steam_id: steam_id, current_game_id: "570"}
      assert steam_id == player.steam_id
    end

    test "persists a play session when a bound player switches games" do
      player = steam_player_fixture(%{display_name: "Player One"})

      summaries =
        start_supervised!(
          {Agent,
           fn ->
             [
               %PlayerSummary{
                 steam_id: player.steam_id,
                 name: "Steam Persona",
                 playing_game_id: "730",
                 playing_game_name: "Counter-Strike 2"
               }
             ]
           end}
        )

      parent = self()

      poller =
        start_supervised!(
          {StatusPoller,
           name: nil,
           interval: false,
           fetch_summaries: fn [_steam_id] -> {:ok, Agent.get(summaries, & &1)} end,
           save_play_session: fn attrs ->
             send(parent, {:saved_play_session, attrs})
             {:ok, attrs}
           end}
        )

      assert {:ok, []} = StatusPoller.check_now(poller)

      Agent.update(summaries, fn _summaries ->
        [
          %PlayerSummary{
            steam_id: player.steam_id,
            name: "Steam Persona",
            playing_game_id: "570",
            playing_game_name: "Dota 2"
          }
        ]
      end)

      assert {:ok, [%StatusChanged{}]} = StatusPoller.check_now(poller)

      assert_receive {:saved_play_session, attrs}
      assert attrs.qq_id == player.qq_id
      assert attrs.steam_id == player.steam_id
      assert attrs.app_id == "730"
      assert attrs.game_name == "Counter-Strike 2"
      assert attrs.player_display_name == "Player One"
      assert attrs.session_end_reason == :switched
      assert %DateTime{} = attrs.started_at
      assert %DateTime{} = attrs.ended_at
      assert attrs.duration_seconds >= 0
    end

    test "persists a play session when a bound player stops playing" do
      player = steam_player_fixture()

      summaries =
        start_supervised!(
          {Agent,
           fn ->
             [
               %PlayerSummary{
                 steam_id: player.steam_id,
                 name: "Steam Persona",
                 playing_game_id: "730",
                 playing_game_name: "Counter-Strike 2"
               }
             ]
           end}
        )

      parent = self()

      poller =
        start_supervised!(
          {StatusPoller,
           name: nil,
           interval: false,
           fetch_summaries: fn [_steam_id] -> {:ok, Agent.get(summaries, & &1)} end,
           save_play_session: fn attrs ->
             send(parent, {:saved_play_session, attrs})
             {:ok, attrs}
           end}
        )

      assert {:ok, []} = StatusPoller.check_now(poller)

      Agent.update(summaries, fn _summaries ->
        [%PlayerSummary{steam_id: player.steam_id, name: "Steam Persona", playing_game_id: nil}]
      end)

      assert {:ok, []} = StatusPoller.check_now(poller)

      assert_receive {:saved_play_session, attrs}
      assert attrs.app_id == "730"
      assert attrs.game_name == "Counter-Strike 2"
      assert attrs.session_end_reason == :stopped
    end

    test "writes finalized play sessions through the Steam context by default" do
      player = steam_player_fixture()

      summaries =
        start_supervised!(
          {Agent,
           fn ->
             [
               %PlayerSummary{
                 steam_id: player.steam_id,
                 name: "Steam Persona",
                 playing_game_id: "730",
                 playing_game_name: "Counter-Strike 2"
               }
             ]
           end}
        )

      poller =
        start_supervised!(
          {StatusPoller,
           name: nil,
           interval: false,
           fetch_summaries: fn [_steam_id] -> {:ok, Agent.get(summaries, & &1)} end}
        )

      assert {:ok, []} = StatusPoller.check_now(poller)

      Agent.update(summaries, fn _summaries ->
        [%PlayerSummary{steam_id: player.steam_id, name: "Steam Persona", playing_game_id: nil}]
      end)

      assert {:ok, []} = StatusPoller.check_now(poller)

      today = Date.utc_today()
      sessions = Steam.list_play_sessions_for_player(player.qq_id, Date.range(today, today))

      assert length(sessions) == 1
      assert hd(sessions).game_name == "Counter-Strike 2"
      assert hd(sessions).session_end_reason == :stopped
    end
  end
end
