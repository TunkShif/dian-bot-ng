defmodule Dian.SteamWatcher.NotifierTest do
  use Dian.DataCase, async: false

  alias Dian.SteamWatcher.Notifier
  alias Dian.Steam.PlayerSummary
  alias Dian.SteamWatcher.StatusChanged

  import Dian.SettingsFixtures

  setup do
    previous_locale = Application.get_env(:dian, :notification_locale)
    previous_avatar_fetcher = Application.get_env(:dian, :steam_avatar_fetcher)

    Application.put_env(:dian, :steam_avatar_fetcher, fn _url ->
      {:ok, "data:image/png;base64,ZmFrZQ=="}
    end)

    on_exit(fn ->
      if previous_locale do
        Application.put_env(:dian, :notification_locale, previous_locale)
      else
        Application.delete_env(:dian, :notification_locale)
      end

      if previous_avatar_fetcher do
        Application.put_env(:dian, :steam_avatar_fetcher, previous_avatar_fetcher)
      else
        Application.delete_env(:dian, :steam_avatar_fetcher)
      end
    end)

    :ok
  end

  describe "handle_info/2" do
    test "delivers Steam status change events" do
      events = start_supervised!({Agent, fn -> [] end})

      notifier =
        start_supervised!(
          {Notifier,
           name: nil,
           subscribe?: false,
           deliver: fn event -> Agent.update(events, &[event | &1]) end}
        )

      event = %StatusChanged{
        steam_id: "76561198000000000",
        qq_id: "12345",
        current_game_id: "730",
        current_game_name: "Counter-Strike 2",
        changed_at: DateTime.utc_now(:second)
      }

      send(notifier, event)
      :sys.get_state(notifier)

      assert Agent.get(events, & &1) == [event]
    end
  end

  describe "format_message/1" do
    test "mentions the QQ user and current game name" do
      event = %StatusChanged{
        steam_id: "76561198000000000",
        qq_id: "12345",
        current_game_id: "730",
        current_game_name: "Counter-Strike 2",
        changed_at: DateTime.utc_now(:second)
      }

      assert Notifier.format_message(event) == "[CQ:at,qq=12345] is now playing Counter-Strike 2"
    end
  end

  describe "build_status_card_svg/1" do
    test "builds an english steam status card" do
      summary = %PlayerSummary{
        steam_id: "76561198826221336",
        name: "Demo Player",
        profile_url: "https://steamcommunity.com/id/demo/",
        avatar_url:
          "https://cdn.cloudflare.steamstatic.com/steamcommunity/public/images/avatars/aa/aaaabbbbccccddddaaaa1111222233334444_full.jpg",
        state: :online,
        playing_game_name: "Counter-Strike 2"
      }

      svg = Notifier.build_status_card_svg(summary, :en)

      assert svg =~ "Demo Player"
      assert svg =~ "is playing"
      assert svg =~ "Counter-Strike 2"
      assert svg =~ "WenQuanYi Micro Hei"
      assert svg =~ "171a21"
      assert svg =~ "data:image/png;base64,ZmFrZQ=="
      refute svg =~ "https://cdn.cloudflare.steamstatic.com"
    end

    test "embeds the avatar as a data uri before rendering" do
      Application.put_env(:dian, :steam_avatar_fetcher, fn _url ->
        {:ok, "data:image/png;base64,ZmFrZQ=="}
      end)

      summary = %PlayerSummary{
        steam_id: "76561198826221336",
        name: "Demo Player",
        profile_url: "https://steamcommunity.com/id/demo/",
        avatar_url:
          "https://cdn.cloudflare.steamstatic.com/steamcommunity/public/images/avatars/aa/aaaabbbbccccddddaaaa1111222233334444_full.jpg",
        state: :online,
        playing_game_name: "Counter-Strike 2"
      }

      svg = Notifier.build_status_card_svg(summary, :en)

      assert svg =~ "data:image/png;base64,ZmFrZQ=="
      refute svg =~ "aaaabbbbccccddddaaaa1111222233334444_full.jpg"
    end

    test "uses the configured locale for chinese copy" do
      summary = %PlayerSummary{
        steam_id: "76561198826221336",
        name: "演示玩家",
        profile_url: "https://steamcommunity.com/id/demo/",
        avatar_url:
          "https://cdn.cloudflare.steamstatic.com/steamcommunity/public/images/avatars/aa/aaaabbbbccccddddaaaa1111222233334444_full.jpg",
        state: :online,
        playing_game_name: "反恐精英 2"
      }

      previous_locale = Application.get_env(:dian, :notification_locale)
      Application.put_env(:dian, :notification_locale, :zh)

      on_exit(fn ->
        if previous_locale do
          Application.put_env(:dian, :notification_locale, previous_locale)
        else
          Application.delete_env(:dian, :notification_locale)
        end
      end)

      svg = Notifier.build_status_card_svg(summary)

      assert svg =~ "演示玩家"
      assert svg =~ "正在游玩"
      assert svg =~ "反恐精英 2"
    end
  end

  describe "notify/1" do
    test "sends a localized text message and rendered status card to enabled groups" do
      enabled_group_setting_fixture(group_id: "100")

      Mox.stub(Dian.Steam.Client.Mock, :get_player_summary, fn "76561198826221336" ->
        %PlayerSummary{
          steam_id: "76561198826221336",
          name: "HHruarua",
          profile_url: "https://steamcommunity.com/id/demo/",
          avatar_url:
            "https://cdn.cloudflare.steamstatic.com/steamcommunity/public/images/avatars/aa/aaaabbbbccccddddaaaa1111222233334444_full.jpg",
          state: :online,
          playing_game_name: "Counter-Strike 2"
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
            %{"type" => "text", "data" => %{"text" => "Demo Card 正在游玩 Counter-Strike 2"}},
            %{"type" => "image", "data" => %{"file" => file}}
          ]
        },
        [] ->
          assert String.starts_with?(file, "base64://")
          {:ok, %{"message_id" => 123_456}}
      end)

      event = %StatusChanged{
        steam_id: "76561198826221336",
        qq_id: "20001",
        current_game_id: "730",
        current_game_name: "Counter-Strike 2",
        changed_at: DateTime.utc_now(:second)
      }

      assert {:ok, 1} = Notifier.notify(event)

      Mox.verify!()
    end
  end
end
