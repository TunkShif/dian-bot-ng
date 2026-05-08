defmodule Dian.SteamWatcher.AchievementNotifierTest do
  use Dian.DataCase, async: false

  alias Dian.Steam.PlayerSummary
  alias Dian.SteamWatcher.AchievementNotifier
  alias Dian.SteamWatcher.AchievementUnlocked

  import Dian.SettingsFixtures

  setup do
    previous_icon_fetcher = Application.get_env(:dian, :steam_achievement_icon_fetcher)

    Application.put_env(:dian, :steam_achievement_icon_fetcher, fn _url ->
      {:ok, "data:image/png;base64,ZmFrZQ=="}
    end)

    on_exit(fn ->
      if previous_icon_fetcher do
        Application.put_env(:dian, :steam_achievement_icon_fetcher, previous_icon_fetcher)
      else
        Application.delete_env(:dian, :steam_achievement_icon_fetcher)
      end
    end)

    :ok
  end

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
    test "sends one notification per achievement when the grouped event contains fewer than three achievements" do
      enabled_group_setting_fixture(group_id: "100")

      Mox.stub(Dian.Steam.Client.Mock, :get_player_summary, fn "76561198826221336" ->
        %PlayerSummary{
          steam_id: "76561198826221336",
          name: "HHruarua",
          profile_url: "https://steamcommunity.com/id/demo/",
          avatar_url: "https://cdn.example/avatar.jpg",
          state: :online
        }
      end)

      Mox.expect(DianBot.Client.Mock, :request, 3, fn
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
                "text" => "Demo Card 在 Counter-Strike 2 中取得了成就：拿下一回合！"
              }
            },
            %{"type" => "image", "data" => %{"file" => file}}
          ]
        },
        [] ->
          assert String.starts_with?(file, "base64://")
          {:ok, %{"message_id" => 123_456}}

        "send_msg",
        %{
          message_type: "group",
          group_id: "100",
          message: [
            %{
              "type" => "text",
              "data" => %{
                "text" => "Demo Card 在 Counter-Strike 2 中取得了成就：开个箱子！"
              }
            },
            %{"type" => "image", "data" => %{"file" => file}}
          ]
        },
        [] ->
          assert String.starts_with?(file, "base64://")
          {:ok, %{"message_id" => 123_457}}
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
            icon_url: "https://cdn.example/win-round.jpg",
            unlocktime: 1_718_171_200
          },
          %AchievementUnlocked.Item{
            api_name: "OPEN_CASE",
            display_name: "开个箱子",
            icon_url: "https://cdn.example/open-case.jpg",
            unlocktime: 1_718_171_300
          }
        ]
      }

      assert {:ok, 2} = AchievementNotifier.notify(event)

      Mox.verify!()
    end

    test "continues sending to later groups when one group send fails" do
      enabled_group_setting_fixture(group_id: "100")
      enabled_group_setting_fixture(group_id: "101")

      Mox.stub(Dian.Steam.Client.Mock, :get_player_summary, fn "76561198826221336" ->
        %PlayerSummary{
          steam_id: "76561198826221336",
          name: "HHruarua",
          profile_url: "https://steamcommunity.com/id/demo/",
          avatar_url: "https://cdn.example/avatar.jpg",
          state: :online
        }
      end)

      Mox.expect(DianBot.Client.Mock, :request, 4, fn
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
                "text" => "Demo Card 在 Counter-Strike 2 中取得了成就：拿下一回合！"
              }
            },
            %{"type" => "image", "data" => %{"file" => file}}
          ]
        },
        [] ->
          assert String.starts_with?(file, "base64://")
          {:error, :timeout}

        "get_group_member_info",
        %{group_id: "101", user_id: "20001", no_cache: true},
        [no_cache: true] ->
          {:ok,
           %{
             "group_id" => "101",
             "user_id" => 20001,
             "nickname" => "Demo Nick 2",
             "card" => "Demo Card 2",
             "join_time" => 0,
             "last_sent_time" => 0,
             "is_robot" => false,
             "role" => "member",
             "title" => ""
           }}

        "send_msg",
        %{
          message_type: "group",
          group_id: "101",
          message: [
            %{
              "type" => "text",
              "data" => %{
                "text" => "Demo Card 2 在 Counter-Strike 2 中取得了成就：拿下一回合！"
              }
            },
            %{"type" => "image", "data" => %{"file" => file}}
          ]
        },
        [] ->
          assert String.starts_with?(file, "base64://")
          {:ok, %{"message_id" => 123_457}}
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
            icon_url: "https://cdn.example/win-round.jpg",
            unlocktime: 1_718_171_200
          }
        ]
      }

      assert {:ok, 1} = AchievementNotifier.notify(event)

      Mox.verify!()
    end

    test "sends one grouped localized notification when the grouped event contains three or more achievements" do
      enabled_group_setting_fixture(group_id: "100")

      Mox.stub(Dian.Steam.Client.Mock, :get_player_summary, fn "76561198826221336" ->
        %PlayerSummary{
          steam_id: "76561198826221336",
          name: "HHruarua",
          profile_url: "https://steamcommunity.com/id/demo/",
          avatar_url: "https://cdn.example/avatar.jpg",
          state: :online
        }
      end)

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
                "text" => "Demo Card 在 Counter-Strike 2 中取得了 3 个成就：拿下一回合，开个箱子，三杀王！"
              }
            },
            %{"type" => "image", "data" => %{"file" => file}}
          ]
        },
        [] ->
          assert String.starts_with?(file, "base64://")
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
            icon_url: "https://cdn.example/win-round.jpg",
            unlocktime: 1_718_171_200
          },
          %AchievementUnlocked.Item{
            api_name: "OPEN_CASE",
            display_name: "开个箱子",
            icon_url: "https://cdn.example/open-case.jpg",
            unlocktime: 1_718_171_300
          },
          %AchievementUnlocked.Item{
            api_name: "TRIPLE_KILL",
            display_name: "三杀王",
            icon_url: "https://cdn.example/triple-kill.jpg",
            unlocktime: 1_718_171_400
          }
        ]
      }

      assert {:ok, 1} = AchievementNotifier.notify(event)

      Mox.verify!()
    end

    test "includes the count in grouped English achievement notifications" do
      previous_locale = Application.get_env(:dian, :notification_locale)
      Application.put_env(:dian, :notification_locale, :en)

      on_exit(fn ->
        if previous_locale do
          Application.put_env(:dian, :notification_locale, previous_locale)
        else
          Application.delete_env(:dian, :notification_locale)
        end
      end)

      enabled_group_setting_fixture(group_id: "100")

      Mox.stub(Dian.Steam.Client.Mock, :get_player_summary, fn "76561198826221336" ->
        %PlayerSummary{
          steam_id: "76561198826221336",
          name: "HHruarua",
          profile_url: "https://steamcommunity.com/id/demo/",
          avatar_url: "https://cdn.example/avatar.jpg",
          state: :online
        }
      end)

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
                "text" =>
                  "Demo Card unlocked 3 achievements in Counter-Strike 2: WIN_ROUND, OPEN_CASE, TRIPLE_KILL!"
              }
            },
            %{"type" => "image", "data" => %{"file" => file}}
          ]
        },
        [] ->
          assert String.starts_with?(file, "base64://")
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
            icon_url: "https://cdn.example/win-round.jpg",
            unlocktime: 1_718_171_200
          },
          %AchievementUnlocked.Item{
            api_name: "OPEN_CASE",
            icon_url: "https://cdn.example/open-case.jpg",
            unlocktime: 1_718_171_300
          },
          %AchievementUnlocked.Item{
            api_name: "TRIPLE_KILL",
            icon_url: "https://cdn.example/triple-kill.jpg",
            unlocktime: 1_718_171_400
          }
        ]
      }

      assert {:ok, 1} = AchievementNotifier.notify(event)

      Mox.verify!()
    end
  end

  describe "build_achievement_card_svg/1" do
    test "builds an achievement card using the first grouped achievement" do
      Mox.stub(Dian.Steam.Client.Mock, :get_player_summary, fn "76561198826221336" ->
        %PlayerSummary{
          steam_id: "76561198826221336",
          name: "HHruarua",
          profile_url: "https://steamcommunity.com/id/demo/",
          avatar_url: "https://cdn.example/avatar.jpg",
          state: :online
        }
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
            icon_url: "https://cdn.example/win-round.jpg",
            unlocktime: 1_718_171_200
          },
          %AchievementUnlocked.Item{
            api_name: "OPEN_CASE",
            display_name: "开个箱子",
            icon_url: "https://cdn.example/open-case.jpg",
            unlocktime: 1_718_171_300
          }
        ]
      }

      svg = AchievementNotifier.build_achievement_card_svg(event)

      assert svg =~ "HHruarua"
      assert svg =~ "Counter-Strike 2"
      assert svg =~ "拿下一回合"
      assert svg =~ "data:image/png;base64,ZmFrZQ=="
      refute svg =~ "https://cdn.example/win-round.jpg"
    end
  end
end
