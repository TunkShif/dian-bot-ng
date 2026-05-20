defmodule DianBot.Commands.Handlers.SteamStatusTest do
  use Dian.DataCase

  import Dian.SteamFixtures

  alias Dian.Steam.PlayerSummary
  alias DianBot.Commands.CommandRequest
  alias DianBot.Commands.Handlers.SteamStatus

  describe "cmds/0" do
    test "returns the steam:status command entry" do
      [entry] = SteamStatus.cmds()
      assert entry.command == "steam:status"
      assert entry.aliases == ["zgsm"]
      assert entry.type == :immediate
      assert entry.mention_required? == true
    end
  end

  describe "parse_args/2" do
    test "extracts qq_id from @-mention in extra_segments" do
      assert SteamStatus.parse_args("", [%{type: "at", data: %{"qq" => "123456"}}]) ==
               {:ok, "123456"}
    end

    test "extracts qq_id ignoring text args" do
      assert SteamStatus.parse_args("some text", [%{type: "at", data: %{"qq" => "789"}}]) ==
               {:ok, "789"}
    end

    test "returns error when no @-mention in extra_segments" do
      assert SteamStatus.parse_args("", []) == {:error, "请 @ 一个用户"}
    end

    test "returns error when extra_segments are non-at segments" do
      assert SteamStatus.parse_args("", [%{type: "image", data: %{"file" => "x.jpg"}}]) ==
               {:error, "请 @ 一个用户"}
    end
  end

  describe "handle/2" do
    test "replies with no binding message when qq_id has no binding" do
      request = %CommandRequest{}

      assert SteamStatus.handle(request, "nonexistent") ==
               {:reply, "未绑定 Steam 账号，请联系管理员绑定"}
    end

    test "replies with error message on Steam API failure" do
      player = steam_player_fixture()

      Mox.expect(Dian.Steam.Client.Mock, :get_player_summaries, fn [_steam_id] ->
        {:error, :timeout}
      end)

      request = %CommandRequest{}

      assert SteamStatus.handle(request, player.qq_id) ==
               {:reply, "Steam API 查询失败，请稍后重试"}

      Mox.verify!()
    end

    test "replies with game summary when player is playing a game" do
      player = steam_player_fixture()

      summary = %PlayerSummary{
        steam_id: player.steam_id,
        name: "CSGOPlayer",
        state: :online,
        playing_game_id: "730",
        playing_game_name: "Counter-Strike 2"
      }

      Mox.expect(Dian.Steam.Client.Mock, :get_player_summaries, fn [_steam_id] ->
        {:ok, [summary]}
      end)

      request = %CommandRequest{}
      result = SteamStatus.handle(request, player.qq_id)

      assert result ==
               {:reply,
                [
                  DianBot.Message.at(player.qq_id),
                  DianBot.Message.text(" 🎮 CSGOPlayer 正在游玩 Counter-Strike 2")
                ]}

      Mox.verify!()
    end

    test "replies with online status when player is online but not playing" do
      player = steam_player_fixture()

      summary = %PlayerSummary{
        steam_id: player.steam_id,
        name: "OnlinePlayer",
        state: :online,
        playing_game_name: nil
      }

      Mox.expect(Dian.Steam.Client.Mock, :get_player_summaries, fn [_steam_id] ->
        {:ok, [summary]}
      end)

      request = %CommandRequest{}
      result = SteamStatus.handle(request, player.qq_id)

      assert result ==
               {:reply,
                [
                  DianBot.Message.at(player.qq_id),
                  DianBot.Message.text(" 💻 OnlinePlayer 状态：🟢 在线")
                ]}

      Mox.verify!()
    end

    test "replies with offline status when player is offline" do
      player = steam_player_fixture()

      summary = %PlayerSummary{
        steam_id: player.steam_id,
        name: "OfflinePlayer",
        state: :offline,
        playing_game_name: nil
      }

      Mox.expect(Dian.Steam.Client.Mock, :get_player_summaries, fn [_steam_id] ->
        {:ok, [summary]}
      end)

      request = %CommandRequest{}
      result = SteamStatus.handle(request, player.qq_id)

      assert result ==
               {:reply,
                [
                  DianBot.Message.at(player.qq_id),
                  DianBot.Message.text(" 💻 OfflinePlayer 状态：⚫ 离线")
                ]}

      Mox.verify!()
    end
  end
end
