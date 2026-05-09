defmodule Dian.SteamTest do
  use Dian.DataCase

  alias Dian.Steam
  alias Dian.Steam.AchievementSnapshot
  alias Dian.Steam.GameSchema
  alias Dian.Steam.PlayerAchievement
  alias Dian.Steam.SteamPlayer

  import Dian.SteamFixtures

  describe "list_steam_players/0" do
    test "returns empty list when no bindings exist" do
      assert Steam.list_steam_players() == []
    end

    test "returns all steam player bindings" do
      player = steam_player_fixture()
      assert [%SteamPlayer{}] = Steam.list_steam_players()
      assert hd(Steam.list_steam_players()).id == player.id
    end
  end

  describe "get_steam_player_by_steam_id/1" do
    test "returns nil when steam_id does not exist" do
      refute Steam.get_steam_player_by_steam_id("76561198000000000")
    end

    test "returns the binding when steam_id exists" do
      player = steam_player_fixture()
      assert %SteamPlayer{} = Steam.get_steam_player_by_steam_id(player.steam_id)
    end
  end

  describe "get_steam_player_by_qq_id/1" do
    test "returns nil when qq_id does not exist" do
      refute Steam.get_steam_player_by_qq_id("nonexistent")
    end

    test "returns the binding when qq_id exists" do
      player = steam_player_fixture()
      assert %SteamPlayer{} = Steam.get_steam_player_by_qq_id(player.qq_id)
    end
  end

  describe "bind_steam_player/1" do
    test "creates a binding with valid attributes" do
      attrs = valid_steam_player_attributes()

      assert {:ok, %SteamPlayer{} = player} = Steam.bind_steam_player(attrs)
      assert player.steam_id == attrs.steam_id
      assert player.qq_id == attrs.qq_id
      assert player.display_name == nil
    end

    test "creates a binding with optional display_name" do
      attrs = valid_steam_player_attributes(%{display_name: "Player One"})

      assert {:ok, %SteamPlayer{} = player} = Steam.bind_steam_player(attrs)
      assert player.display_name == "Player One"
    end

    test "returns error on duplicate steam_id" do
      player = steam_player_fixture()

      {:error, changeset} =
        Steam.bind_steam_player(%{steam_id: player.steam_id, qq_id: unique_qq_id()})

      assert "has already been taken" in errors_on(changeset).steam_id
    end

    test "returns error on duplicate qq_id" do
      player = steam_player_fixture()

      {:error, changeset} =
        Steam.bind_steam_player(%{steam_id: unique_steam_id(), qq_id: player.qq_id})

      assert "has already been taken" in errors_on(changeset).qq_id
    end

    test "validates required fields" do
      {:error, changeset} = Steam.bind_steam_player(%{})

      assert %{steam_id: ["can't be blank"], qq_id: ["can't be blank"]} =
               errors_on(changeset)
    end
  end

  describe "unbind_steam_player/1" do
    test "deletes an existing binding" do
      player = steam_player_fixture()
      assert :ok = Steam.unbind_steam_player(player.steam_id)
      refute Steam.get_steam_player_by_steam_id(player.steam_id)
    end

    test "returns error when binding does not exist" do
      assert {:error, :not_found} = Steam.unbind_steam_player("nonexistent")
    end
  end

  describe "change_steam_player/2" do
    test "returns a changeset" do
      player = steam_player_fixture()
      assert %Ecto.Changeset{} = Steam.change_steam_player(player)
    end

    test "allows fields to be set" do
      player = steam_player_fixture()
      changeset = Steam.change_steam_player(player, %{display_name: "Updated"})
      assert Ecto.Changeset.get_change(changeset, :display_name) == "Updated"
    end
  end

  describe "get_player_summary/1" do
    test "delegates to the configured Steam client" do
      summary = %Steam.PlayerSummary{
        steam_id: "76561198000000000",
        playing_game_id: "730",
        playing_game_name: "Counter-Strike 2"
      }

      Mox.expect(Dian.Steam.Client.Mock, :get_player_summary, fn "76561198000000000" ->
        summary
      end)

      assert Steam.get_player_summary("76561198000000000") == summary

      Mox.verify!()
    end
  end

  describe "get_player_summaries/1" do
    test "delegates to the configured Steam client" do
      summaries = [
        %Steam.PlayerSummary{
          steam_id: "76561198000000000",
          playing_game_id: "730",
          playing_game_name: "Counter-Strike 2"
        }
      ]

      Mox.expect(Dian.Steam.Client.Mock, :get_player_summaries, fn ["76561198000000000"] ->
        {:ok, summaries}
      end)

      assert Steam.get_player_summaries(["76561198000000000"]) == {:ok, summaries}

      Mox.verify!()
    end
  end

  describe "get_player_achievements/3" do
    test "delegates to the configured Steam client" do
      achievements = [
        %PlayerAchievement{
          api_name: "PLAY_CS2",
          achieved?: true,
          unlocktime: 1_718_171_077,
          display_name: "全新的开始"
        }
      ]

      Mox.expect(
        Dian.Steam.Client.Mock,
        :get_player_achievements,
        fn "76561198000000000", "730", :zh -> {:ok, achievements} end
      )

      assert Steam.get_player_achievements("76561198000000000", "730", :zh) ==
               {:ok, achievements}

      Mox.verify!()
    end
  end

  describe "get_game_schema/2" do
    test "delegates to the configured Steam client" do
      schema = %GameSchema{
        app_id: "730",
        game_name: "Counter-Strike 2",
        achievements: %{}
      }

      Mox.expect(Dian.Steam.Client.Mock, :get_game_schema, fn "730", :zh -> {:ok, schema} end)

      assert Steam.get_game_schema("730", :zh) == {:ok, schema}

      Mox.verify!()
    end
  end

  describe "achievement snapshots" do
    test "upsert_achievement_snapshot/1 creates and updates a snapshot" do
      attrs = %{
        steam_id: unique_steam_id(),
        qq_id: unique_qq_id(),
        app_id: "730",
        game_name: "Counter-Strike 2",
        unlocked_achievements: %{"PLAY_CS2" => %{"unlocktime" => 1_718_171_077}},
        completion_state: :active,
        last_checked_at: DateTime.utc_now(:second)
      }

      assert {:ok, %AchievementSnapshot{} = snapshot} = Steam.upsert_achievement_snapshot(attrs)
      assert snapshot.game_name == "Counter-Strike 2"

      updated_attrs =
        Map.merge(attrs, %{
          game_name: "CS2",
          completion_state: :fully_unlocked
        })

      assert {:ok, %AchievementSnapshot{} = updated_snapshot} =
               Steam.upsert_achievement_snapshot(updated_attrs)

      assert updated_snapshot.game_name == "CS2"
      assert updated_snapshot.completion_state == :fully_unlocked

      assert %AchievementSnapshot{} =
               stored =
               Steam.get_achievement_snapshot(attrs.steam_id, attrs.app_id)

      assert stored.game_name == "CS2"
      assert stored.completion_state == :fully_unlocked
    end

    test "delete_achievement_snapshot/2 deletes an existing snapshot" do
      attrs = %{
        steam_id: unique_steam_id(),
        qq_id: unique_qq_id(),
        app_id: "730",
        unlocked_achievements: %{},
        completion_state: :active
      }

      assert {:ok, %AchievementSnapshot{}} = Steam.upsert_achievement_snapshot(attrs)
      assert :ok = Steam.delete_achievement_snapshot(attrs.steam_id, attrs.app_id)
      assert Steam.get_achievement_snapshot(attrs.steam_id, attrs.app_id) == nil
    end

    test "delete_achievement_snapshot/2 returns ok when the snapshot does not exist" do
      assert :ok = Steam.delete_achievement_snapshot(unique_steam_id(), "730")
    end
  end

  describe "play sessions" do
    test "create_play_session/1 persists a finalized play session" do
      attrs = %{
        qq_id: unique_qq_id(),
        steam_id: unique_steam_id(),
        app_id: "730",
        game_name: "Counter-Strike 2",
        player_display_name: "Player One",
        started_at: ~U[2026-05-09 10:00:00Z],
        ended_at: ~U[2026-05-09 10:30:00Z],
        duration_seconds: 1800,
        session_end_reason: :stopped
      }

      assert {:ok, session} = Steam.create_play_session(attrs)
      assert session.qq_id == attrs.qq_id
      assert session.steam_id == attrs.steam_id
      assert session.app_id == "730"
      assert session.game_name == "Counter-Strike 2"
      assert session.player_display_name == "Player One"
      assert session.duration_seconds == 1800
      assert session.session_end_reason == :stopped
    end

    test "list_play_sessions_for_players/2 returns sessions overlapping the date range" do
      qq_id = unique_qq_id()

      assert {:ok, _session} =
               Steam.create_play_session(%{
                 qq_id: qq_id,
                 steam_id: unique_steam_id(),
                 app_id: "730",
                 game_name: "Counter-Strike 2",
                 started_at: ~U[2026-05-08 23:50:00Z],
                 ended_at: ~U[2026-05-09 00:20:00Z],
                 duration_seconds: 1800,
                 session_end_reason: :stopped
               })

      assert {:ok, _session} =
               Steam.create_play_session(%{
                 qq_id: qq_id,
                 steam_id: unique_steam_id(),
                 app_id: "570",
                 game_name: "Dota 2",
                 started_at: ~U[2026-05-10 09:00:00Z],
                 ended_at: ~U[2026-05-10 09:30:00Z],
                 duration_seconds: 1800,
                 session_end_reason: :stopped
               })

      sessions =
        Steam.list_play_sessions_for_players([qq_id], Date.range(~D[2026-05-09], ~D[2026-05-09]))

      assert length(sessions) == 1
      assert hd(sessions).game_name == "Counter-Strike 2"
    end
  end
end
