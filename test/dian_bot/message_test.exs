defmodule DianBot.MessageTest do
  use ExUnit.Case, async: true

  alias DianBot.Message

  test "build/1 parses documented message payload fields" do
    payload = %{
      "real_seq" => "42",
      "temp_source" => 1,
      "message_sent_type" => "normal",
      "target_id" => 100,
      "self_id" => 200,
      "time" => 1_713_456_789,
      "message_id" => 300,
      "message_seq" => 301,
      "real_id" => 302,
      "user_id" => 400,
      "group_id" => 500,
      "group_name" => "Dian Group",
      "message_type" => "group",
      "sub_type" => "normal",
      "sender" => %{
        "user_id" => 400,
        "nickname" => "Dian User",
        "sex" => "male",
        "age" => 18,
        "card" => "Card Name",
        "level" => "12",
        "role" => "admin"
      },
      "message" => [
        %{"type" => "text", "data" => %{"text" => "hello"}},
        %{"type" => "reply", "data" => %{"id" => "123"}}
      ],
      "message_format" => "array",
      "raw_message" => "hello",
      "font" => "Arial",
      "post_type" => "message",
      "raw" => "{\"raw\":true}"
    }

    assert Message.build(payload) == %Message{
             real_seq: "42",
             temp_source: 1,
             message_sent_type: "normal",
             target_id: 100,
             self_id: 200,
             time: 1_713_456_789,
             message_id: 300,
             message_seq: 301,
             real_id: 302,
             user_id: 400,
             group_id: 500,
             group_name: "Dian Group",
             message_type: "group",
             sub_type: "normal",
             sender: %{
               user_id: 400,
               nickname: "Dian User",
               sex: "male",
               age: 18,
               card: "Card Name",
               level: "12",
               role: "admin"
             },
             message: [
               %{type: "text", data: %{"text" => "hello"}},
               %{type: "reply", data: %{"id" => "123"}}
             ],
             message_format: "array",
             raw_message: "hello",
             font: "Arial",
             post_type: "message",
             raw: "{\"raw\":true}"
           }
  end

  test "to_payload/1 serializes strings, segments, and message structs for send_msg" do
    built_message = %Message{
      message: [
        Message.text("hello"),
        Message.reply("123")
      ]
    }

    assert Message.to_payload("plain text") == [
             %{"type" => "text", "data" => %{"text" => "plain text"}}
           ]

    assert Message.to_payload([Message.text("hello"), %{type: "at", data: %{qq: "12345"}}]) == [
             %{"type" => "text", "data" => %{"text" => "hello"}},
             %{"type" => "at", "data" => %{"qq" => "12345"}}
           ]

    assert Message.to_payload(built_message) == [
             %{"type" => "text", "data" => %{"text" => "hello"}},
             %{"type" => "reply", "data" => %{"id" => "123"}}
           ]
  end
end
