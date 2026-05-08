defmodule Dian.Steam.Client.DefaultTest do
  use ExUnit.Case, async: false

  alias Dian.Steam.Client.Default
  alias Dian.Steam.GameSchema
  alias Dian.Steam.PlayerAchievement
  alias Dian.Steam.PlayerSummary

  setup do
    Req.Test.verify_on_exit!()
  end

  test "get_player_summaries/1 fetches and normalizes Steam player summaries" do
    Req.Test.expect(Default, fn conn ->
      assert conn.request_path == "/ISteamUser/GetPlayerSummaries/v0002/"
      assert URI.decode_query(conn.query_string)["steamids"] == "76561198000000000"

      Req.Test.json(conn, %{
        "response" => %{
          "players" => [
            %{
              "steamid" => "76561198000000000",
              "personaname" => "test player",
              "profileurl" => "https://steamcommunity.com/id/test-player",
              "avatarfull" => "https://cdn.example/avatar.jpg",
              "personastate" => 1,
              "lastlogoff" => 1_700_000_000,
              "timecreated" => 1_600_000_000,
              "gameid" => "730",
              "gameextrainfo" => "Counter-Strike 2"
            }
          ]
        }
      })
    end)

    assert {:ok, [%PlayerSummary{} = summary]} =
             Default.get_player_summaries(["76561198000000000"])

    assert summary.steam_id == "76561198000000000"
    assert summary.name == "test player"
    assert summary.state == :online
    assert summary.playing_game_id == "730"
    assert summary.playing_game_name == "Counter-Strike 2"
  end

  test "get_player_summary/1 returns the first fetched summary" do
    Req.Test.expect(Default, fn conn ->
      Req.Test.json(conn, %{
        "response" => %{
          "players" => [
            %{
              "steamid" => "76561198000000000",
              "personaname" => "test player",
              "personastate" => 0
            }
          ]
        }
      })
    end)

    assert %PlayerSummary{steam_id: "76561198000000000", state: :offline} =
             Default.get_player_summary("76561198000000000")
  end

  test "get_player_summaries/1 returns request_error for non-200 responses" do
    Req.Test.expect(Default, fn conn ->
      Plug.Conn.resp(conn, 500, "server error")
    end)

    assert Default.get_player_summaries(["76561198000000000"]) == {:error, :request_error}
  end

  test "get_player_achievements/3 fetches and normalizes player achievements" do
    Req.Test.expect(Default, fn conn ->
      query = URI.decode_query(conn.query_string)

      assert conn.request_path == "/ISteamUserStats/GetPlayerAchievements/v0001/"
      assert query["steamid"] == "76561198000000000"
      assert query["appid"] == "730"
      assert query["l"] == "schinese"

      Req.Test.json(conn, %{
        "playerstats" => %{
          "steamID" => "76561198000000000",
          "gameName" => "Counter-Strike 2",
          "success" => true,
          "achievements" => [
            %{
              "apiname" => "PLAY_CS2",
              "achieved" => 1,
              "unlocktime" => 1_718_171_077,
              "name" => "全新的开始",
              "description" => ""
            }
          ]
        }
      })
    end)

    assert {:ok, [%PlayerAchievement{} = achievement]} =
             Default.get_player_achievements("76561198000000000", "730", :zh)

    assert achievement.api_name == "PLAY_CS2"
    assert achievement.achieved? == true
    assert achievement.unlocktime == 1_718_171_077
    assert achievement.display_name == "全新的开始"
    assert achievement.description == ""
  end

  test "get_player_achievements/3 returns no_stats when the game has no stats" do
    Req.Test.expect(Default, fn conn ->
      Req.Test.json(conn, %{
        "playerstats" => %{
          "error" => "Requested app has no stats",
          "success" => false
        }
      })
    end)

    assert Default.get_player_achievements("76561198000000000", "730", :zh) == {:error, :no_stats}
  end

  test "get_game_schema/2 fetches and normalizes achievement schema" do
    Req.Test.expect(Default, fn conn ->
      query = URI.decode_query(conn.query_string)

      assert conn.request_path == "/ISteamUserStats/GetSchemaForGame/v0002/"
      assert query["appid"] == "1245620"
      assert query["l"] == "schinese"
      assert query["format"] == "json"

      Req.Test.json(conn, %{
        "game" => %{
          "gameName" => "ELDEN RING",
          "gameVersion" => "47",
          "availableGameStats" => %{
            "achievements" => [
              %{
                "name" => "ACH01",
                "displayName" => "艾尔登之王",
                "hidden" => 1,
                "icon" => "https://cdn.example/ach01.jpg",
                "icongray" => "https://cdn.example/ach01-gray.jpg"
              }
            ]
          }
        }
      })
    end)

    assert {:ok, %GameSchema{} = schema} = Default.get_game_schema("1245620", :zh)
    assert schema.app_id == "1245620"
    assert schema.game_name == "ELDEN RING"
    assert schema.game_version == "47"

    assert %GameSchema.Achievement{
             api_name: "ACH01",
             display_name: "艾尔登之王",
             hidden: true,
             icon_url: "https://cdn.example/ach01.jpg",
             icon_gray_url: "https://cdn.example/ach01-gray.jpg"
           } = Map.fetch!(schema.achievements, "ACH01")
  end
end
