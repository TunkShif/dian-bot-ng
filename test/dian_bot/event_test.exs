defmodule DianBot.EventTest do
  use ExUnit.Case, async: true

  alias DianBot.Event
  alias DianBot.Event.GroupMessageEvent

  test "builds group message events with all advertised fields" do
    payload = %{
      "post_type" => "message",
      "message_type" => "group",
      "group_id" => 456,
      "sender" => %{"user_id" => 789},
      "message" => [%{"type" => "text", "data" => %{"text" => "hello"}}],
      "raw_message" => "hello",
      "time" => 1_713_456_789
    }

    assert Event.build(payload) == %GroupMessageEvent{
             group_id: 456,
             sender_id: 789,
             message: [%{"type" => "text", "data" => %{"text" => "hello"}}],
             raw_message: "hello",
             timestamp: 1_713_456_789
           }
  end

  test "returns nil for unsupported payloads" do
    assert Event.build(%{"post_type" => "notice", "notice_type" => "group_upload"}) == nil
  end

  test "does not crash when sender is missing" do
    payload = %{
      "post_type" => "message",
      "message_type" => "group",
      "group_id" => 456,
      "message" => [],
      "raw_message" => "",
      "time" => 1_713_456_789
    }

    assert %GroupMessageEvent{sender_id: nil, timestamp: 1_713_456_789} = Event.build(payload)
  end

  test "does not crash when sender is malformed" do
    payload = %{
      "post_type" => "message",
      "message_type" => "group",
      "group_id" => 456,
      "sender" => "malformed",
      "message" => [],
      "raw_message" => "",
      "time" => 1_713_456_789
    }

    assert %GroupMessageEvent{sender_id: nil, timestamp: 1_713_456_789} = Event.build(payload)
  end
end
