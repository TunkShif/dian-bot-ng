defmodule Dian.SteamWatcher.AchievementPollerTest do
  use Dian.DataCase

  alias Dian.Steam.GameSchema
  alias Dian.Steam.GameSchema.Achievement
  alias Dian.Steam.PlayerAchievement
  alias Dian.Steam.PlayerSummary
  alias Dian.SteamWatcher.AchievementPoller
  alias Dian.SteamWatcher.AchievementUnlocked

  import Dian.SteamFixtures

  describe "check_now/1" do
    test "uses the first in-game observation as a baseline without broadcasting unlocks" do
      player = steam_player_fixture()

      achievements =
        start_supervised!(%{
          id: :achievement_baseline_agent,
          start:
            {Agent, :start_link,
             [
               fn ->
                 [
                   %PlayerAchievement{
                     api_name: "PLAY_CS2",
                     achieved?: true,
                     unlocktime: 1_718_171_077,
                     display_name: "全新的开始"
                   },
                   %PlayerAchievement{
                     api_name: "WIN_ROUND",
                     achieved?: false,
                     unlocktime: 0,
                     display_name: "拿下一回合"
                   }
                 ]
               end
             ]}
        })

      poller =
        start_supervised!(
          {AchievementPoller,
           name: nil,
           interval: false,
           list_bindings: fn -> [player] end,
           fetch_summaries: fn [_steam_id] ->
             {:ok,
              [
                %PlayerSummary{
                  steam_id: player.steam_id,
                  playing_game_id: "730",
                  playing_game_name: "Counter-Strike 2"
                }
              ]}
           end,
           fetch_achievements: fn steam_id, "730", :zh ->
             assert steam_id == player.steam_id
             {:ok, Agent.get(achievements, & &1)}
           end,
           get_game_schema: fn "730", :zh ->
             {:ok,
              %GameSchema{
                app_id: "730",
                game_name: "Counter-Strike 2",
                achievements: %{}
              }}
           end}
        )

      AchievementPoller.subscribe()

      assert {:ok, []} = AchievementPoller.check_now(poller)
      refute_receive %AchievementUnlocked{}
    end

    test "groups multiple unlocked achievements into a single event" do
      player = steam_player_fixture()

      achievements =
        start_supervised!(%{
          id: :achievement_group_agent,
          start:
            {Agent, :start_link,
             [
               fn ->
                 [
                   %PlayerAchievement{
                     api_name: "PLAY_CS2",
                     achieved?: true,
                     unlocktime: 1_718_171_077,
                     display_name: "全新的开始"
                   },
                   %PlayerAchievement{
                     api_name: "WIN_ROUND",
                     achieved?: false,
                     unlocktime: 0,
                     display_name: "拿下一回合"
                   },
                   %PlayerAchievement{
                     api_name: "OPEN_CASE",
                     achieved?: false,
                     unlocktime: 0,
                     display_name: "开个箱子"
                   }
                 ]
               end
             ]}
        })

      schema = %GameSchema{
        app_id: "730",
        game_name: "Counter-Strike 2",
        achievements: %{
          "PLAY_CS2" => %Achievement{
            api_name: "PLAY_CS2",
            display_name: "全新的开始",
            icon_url: "https://cdn.example/play-cs2.jpg"
          },
          "WIN_ROUND" => %Achievement{
            api_name: "WIN_ROUND",
            display_name: "拿下一回合",
            icon_url: "https://cdn.example/win-round.jpg"
          },
          "OPEN_CASE" => %Achievement{
            api_name: "OPEN_CASE",
            display_name: "开个箱子",
            icon_url: "https://cdn.example/open-case.jpg"
          }
        }
      }

      poller =
        start_supervised!(
          {AchievementPoller,
           name: nil,
           interval: false,
           list_bindings: fn -> [player] end,
           fetch_summaries: fn [_steam_id] ->
             {:ok,
              [
                %PlayerSummary{
                  steam_id: player.steam_id,
                  playing_game_id: "730",
                  playing_game_name: "Counter-Strike 2"
                }
              ]}
           end,
           fetch_achievements: fn steam_id, "730", :zh ->
             assert steam_id == player.steam_id
             {:ok, Agent.get(achievements, & &1)}
           end,
           get_game_schema: fn "730", :zh -> {:ok, schema} end}
        )

      AchievementPoller.subscribe()

      assert {:ok, []} = AchievementPoller.check_now(poller)

      Agent.update(achievements, fn _ ->
        [
          %PlayerAchievement{
            api_name: "PLAY_CS2",
            achieved?: true,
            unlocktime: 1_718_171_077,
            display_name: "全新的开始"
          },
          %PlayerAchievement{
            api_name: "WIN_ROUND",
            achieved?: true,
            unlocktime: 1_718_171_200,
            display_name: "拿下一回合"
          },
          %PlayerAchievement{
            api_name: "OPEN_CASE",
            achieved?: true,
            unlocktime: 1_718_171_300,
            display_name: "开个箱子"
          }
        ]
      end)

      assert {:ok, [%AchievementUnlocked{} = event]} = AchievementPoller.check_now(poller)
      assert event.steam_id == player.steam_id
      assert event.qq_id == player.qq_id
      assert event.app_id == "730"
      assert event.game_name == "Counter-Strike 2"
      assert Enum.map(event.achievements, & &1.api_name) == ["WIN_ROUND", "OPEN_CASE"]
      assert Enum.all?(event.achievements, &is_binary(&1.icon_url))

      assert_receive %AchievementUnlocked{steam_id: steam_id, achievements: achievements}
      assert steam_id == player.steam_id
      assert length(achievements) == 2
    end

    test "performs a final achievement check when the player leaves the game" do
      player = steam_player_fixture()

      summaries =
        start_supervised!(%{
          id: :achievement_final_summaries_agent,
          start:
            {Agent, :start_link,
             [
               fn ->
                 [
                   %PlayerSummary{
                     steam_id: player.steam_id,
                     playing_game_id: "730",
                     playing_game_name: "Counter-Strike 2"
                   }
                 ]
               end
             ]}
        })

      achievements =
        start_supervised!(%{
          id: :achievement_final_achievements_agent,
          start:
            {Agent, :start_link,
             [
               fn ->
                 [
                   %PlayerAchievement{
                     api_name: "PLAY_CS2",
                     achieved?: true,
                     unlocktime: 1_718_171_077,
                     display_name: "全新的开始"
                   },
                   %PlayerAchievement{
                     api_name: "WIN_ROUND",
                     achieved?: false,
                     unlocktime: 0,
                     display_name: "拿下一回合"
                   }
                 ]
               end
             ]}
        })

      poller =
        start_supervised!(
          {AchievementPoller,
           name: nil,
           interval: false,
           list_bindings: fn -> [player] end,
           fetch_summaries: fn [_steam_id] -> {:ok, Agent.get(summaries, & &1)} end,
           fetch_achievements: fn steam_id, "730", :zh ->
             assert steam_id == player.steam_id
             {:ok, Agent.get(achievements, & &1)}
           end,
           get_game_schema: fn "730", :zh ->
             {:ok,
              %GameSchema{
                app_id: "730",
                game_name: "Counter-Strike 2",
                achievements: %{
                  "PLAY_CS2" => %Achievement{api_name: "PLAY_CS2"},
                  "WIN_ROUND" => %Achievement{
                    api_name: "WIN_ROUND",
                    display_name: "拿下一回合",
                    icon_url: "https://cdn.example/win-round.jpg"
                  }
                }
              }}
           end}
        )

      AchievementPoller.subscribe()

      assert {:ok, []} = AchievementPoller.check_now(poller)

      Agent.update(achievements, fn _ ->
        [
          %PlayerAchievement{
            api_name: "PLAY_CS2",
            achieved?: true,
            unlocktime: 1_718_171_077,
            display_name: "全新的开始"
          },
          %PlayerAchievement{
            api_name: "WIN_ROUND",
            achieved?: true,
            unlocktime: 1_718_171_200,
            display_name: "拿下一回合"
          }
        ]
      end)

      Agent.update(summaries, fn _ ->
        [
          %PlayerSummary{
            steam_id: player.steam_id,
            playing_game_id: nil,
            playing_game_name: nil
          }
        ]
      end)

      assert {:ok, [%AchievementUnlocked{} = event]} = AchievementPoller.check_now(poller)
      assert Enum.map(event.achievements, & &1.api_name) == ["WIN_ROUND"]
      assert_receive %AchievementUnlocked{steam_id: steam_id}
      assert steam_id == player.steam_id
    end
  end
end
