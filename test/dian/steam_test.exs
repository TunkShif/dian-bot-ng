defmodule Dian.SteamTest do
  use Dian.DataCase

  alias Dian.Steam
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
end
