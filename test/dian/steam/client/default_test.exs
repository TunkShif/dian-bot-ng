defmodule Dian.Steam.Client.DefaultTest do
  use ExUnit.Case, async: false

  alias Dian.Steam.Client.Default
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
end
