defmodule DianBot.EventBusTest do
  use ExUnit.Case, async: false

  alias DianBot.Event
  alias DianBot.EventBus

  setup do
    EventBus.subscribe()
    :ok
  end

  test "broadcast/1 publishes event to subscribers" do
    event =
      Event.build(%{
        "post_type" => "message",
        "message_type" => "group",
        "group_id" => 123,
        "sender" => %{"user_id" => 456},
        "message" => [%{"type" => "text", "data" => %{"text" => "hello"}}],
        "raw_message" => "hello",
        "time" => 1_713_456_789
      })

    EventBus.broadcast(event)

    assert_receive ^event
  end

  test "broadcast/1 does not raise when no subscribers" do
    # unsubscribe self
    Phoenix.PubSub.unsubscribe(Dian.PubSub, "bot:event")

    event =
      Event.build(%{
        "post_type" => "message",
        "message_type" => "group",
        "group_id" => 123,
        "sender" => %{"user_id" => 456},
        "message" => [],
        "raw_message" => "",
        "time" => 1
      })

    EventBus.broadcast(event)
    refute_receive _
  end
end
