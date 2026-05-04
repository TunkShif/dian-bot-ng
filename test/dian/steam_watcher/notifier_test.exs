defmodule Dian.SteamWatcher.NotifierTest do
  use ExUnit.Case, async: false

  alias Dian.SteamWatcher.Notifier
  alias Dian.SteamWatcher.StatusChanged

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
end
