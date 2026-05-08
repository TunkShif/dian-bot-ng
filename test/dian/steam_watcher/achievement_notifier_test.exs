defmodule Dian.SteamWatcher.AchievementNotifierTest do
  use Dian.DataCase, async: false

  alias Dian.SteamWatcher.AchievementNotifier
  alias Dian.SteamWatcher.AchievementUnlocked

  import Dian.SettingsFixtures

  describe "handle_info/2" do
    test "delivers grouped achievement events" do
      events = start_supervised!({Agent, fn -> [] end})

      notifier =
        start_supervised!(
          {AchievementNotifier,
           name: nil,
           subscribe?: false,
           deliver: fn event -> Agent.update(events, &[event | &1]) end}
        )

      event = %AchievementUnlocked{
        steam_id: "76561198000000000",
        qq_id: "12345",
        app_id: "730",
        game_name: "Counter-Strike 2",
        changed_at: DateTime.utc_now(:second),
        achievements: [
          %AchievementUnlocked.Item{
            api_name: "WIN_ROUND",
            display_name: "拿下一回合",
            unlocktime: 1_718_171_200
          }
        ]
      }

      send(notifier, event)
      :sys.get_state(notifier)

      assert Agent.get(events, & &1) == [event]
    end
  end

  describe "notify/1" do
    test "sends one grouped localized message for all newly unlocked achievements" do
      enabled_group_setting_fixture(group_id: "100")

      Mox.expect(DianBot.Client.Mock, :request, 2, fn
        "get_group_member_info",
        %{group_id: "100", user_id: "20001", no_cache: true},
        [no_cache: true] ->
          {:ok,
           %{
             "group_id" => "100",
             "user_id" => 20001,
             "nickname" => "Demo Nick",
             "card" => "Demo Card",
             "join_time" => 0,
             "last_sent_time" => 0,
             "is_robot" => false,
             "role" => "member",
             "title" => ""
           }}

        "send_msg",
        %{
          message_type: "group",
          group_id: "100",
          message: [
            %{
              "type" => "text",
              "data" => %{
                "text" => "Demo Card 在 Counter-Strike 2 解锁了成就：拿下一回合、开个箱子"
              }
            }
          ]
        },
        [] ->
          {:ok, %{"message_id" => 123_456}}
      end)

      event = %AchievementUnlocked{
        steam_id: "76561198826221336",
        qq_id: "20001",
        app_id: "730",
        game_name: "Counter-Strike 2",
        changed_at: DateTime.utc_now(:second),
        achievements: [
          %AchievementUnlocked.Item{
            api_name: "WIN_ROUND",
            display_name: "拿下一回合",
            unlocktime: 1_718_171_200
          },
          %AchievementUnlocked.Item{
            api_name: "OPEN_CASE",
            display_name: "开个箱子",
            unlocktime: 1_718_171_300
          }
        ]
      }

      assert {:ok, 1} = AchievementNotifier.notify(event)

      Mox.verify!()
    end
  end
end
