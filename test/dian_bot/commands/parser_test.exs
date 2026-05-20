defmodule DianBot.Commands.ParserTest do
  use ExUnit.Case, async: true

  alias DianBot.Commands.Parser
  alias DianBot.Event.GroupMessageEvent
  alias DianBot.Message

  @self_id 123
  @other_id 456

  describe "parse/1" do
    test "parses plain /cmd args" do
      event = %GroupMessageEvent{
        group_id: 1,
        self_id: @self_id,
        sender_id: 789,
        message_id: 100,
        message: [Message.text("/cmd arg1 arg2")],
        raw_message: "/cmd arg1 arg2",
        timestamp: 1_713_456_789
      }

      assert {:ok, request} = Parser.parse(event)
      assert request.name == "cmd"
      assert request.raw_args == "arg1 arg2"
      assert request.mentions_bot? == false
      assert request.reply == nil
      assert request.group_id == 1
      assert request.sender_id == 789
      assert request.message_id == 100
      assert request.timestamp == 1_713_456_789
    end

    test "parses bare /cmd with no args" do
      event = %GroupMessageEvent{
        group_id: 1,
        self_id: @self_id,
        sender_id: 789,
        message_id: 100,
        message: [Message.text("/cmd")],
        raw_message: "/cmd",
        timestamp: 1_713_456_789
      }

      assert {:ok, request} = Parser.parse(event)
      assert request.name == "cmd"
      assert request.raw_args == ""
    end

    test "parses /cmd with @bot mention" do
      event = %GroupMessageEvent{
        group_id: 1,
        self_id: @self_id,
        sender_id: 789,
        message_id: 100,
        message: [Message.at(@self_id), Message.text("/cmd foo")],
        raw_message: "",
        timestamp: 1_713_456_789
      }

      assert {:ok, request} = Parser.parse(event)
      assert request.name == "cmd"
      assert request.raw_args == "foo"
      assert request.mentions_bot? == true
    end

    test "parses /cmd with reply" do
      event = %GroupMessageEvent{
        group_id: 1,
        self_id: @self_id,
        sender_id: 789,
        message_id: 100,
        message: [Message.reply("1289001822"), Message.text("/md quoted message")],
        raw_message: "",
        timestamp: 1_713_456_789
      }

      assert {:ok, request} = Parser.parse(event)
      assert request.name == "md"
      assert request.raw_args == "quoted message"
      assert request.reply == %{message_id: "1289001822"}
    end

    test "parses /cmd with reply and @bot mention" do
      event = %GroupMessageEvent{
        group_id: 1,
        self_id: @self_id,
        sender_id: 789,
        message_id: 100,
        message: [Message.reply("5"), Message.at(@self_id), Message.text("/cmd")],
        raw_message: "",
        timestamp: 1_713_456_789
      }

      assert {:ok, request} = Parser.parse(event)
      assert request.name == "cmd"
      assert request.raw_args == ""
      assert request.reply == %{message_id: "5"}
      assert request.mentions_bot? == true
    end

    test "preserves original event and segments" do
      segments = [Message.text("/foo")]

      event = %GroupMessageEvent{
        group_id: 1,
        self_id: @self_id,
        sender_id: 789,
        message_id: 100,
        message: segments,
        raw_message: "/foo",
        timestamp: 1_713_456_789
      }

      assert {:ok, request} = Parser.parse(event)
      assert request.event == event
      assert request.segments == segments
    end

    test "ignores message with slash later in text" do
      event = %GroupMessageEvent{
        group_id: 1,
        self_id: @self_id,
        sender_id: 789,
        message_id: 100,
        message: [Message.text("hello /cmd")],
        raw_message: "hello /cmd",
        timestamp: 1_713_456_789
      }

      assert Parser.parse(event) == :ignore
    end

    test "ignores message with non-structural segment before command" do
      event = %GroupMessageEvent{
        group_id: 1,
        self_id: @self_id,
        sender_id: 789,
        message_id: 100,
        message: [Message.image("base64://abc"), Message.text("/cmd")],
        raw_message: "",
        timestamp: 1_713_456_789
      }

      assert Parser.parse(event) == :ignore
    end

    test "ignores message with @ of another user before command" do
      event = %GroupMessageEvent{
        group_id: 1,
        self_id: @self_id,
        sender_id: 789,
        message_id: 100,
        message: [Message.at(@other_id), Message.text("/cmd")],
        raw_message: "",
        timestamp: 1_713_456_789
      }

      assert Parser.parse(event) == :ignore
    end

    test "ignores message with no slash at all" do
      event = %GroupMessageEvent{
        group_id: 1,
        self_id: @self_id,
        sender_id: 789,
        message_id: 100,
        message: [Message.text("hello")],
        raw_message: "hello",
        timestamp: 1_713_456_789
      }

      assert Parser.parse(event) == :ignore
    end

    test "handles leading whitespace before slash" do
      event = %GroupMessageEvent{
        group_id: 1,
        self_id: @self_id,
        sender_id: 789,
        message_id: 100,
        message: [Message.text("  /cmd arg")],
        raw_message: "",
        timestamp: 1_713_456_789
      }

      assert {:ok, request} = Parser.parse(event)
      assert request.name == "cmd"
      assert request.raw_args == "arg"
    end

    test "preserves multiple spaces in args" do
      event = %GroupMessageEvent{
        group_id: 1,
        self_id: @self_id,
        sender_id: 789,
        message_id: 100,
        message: [Message.text("/cmd  arg1  arg2")],
        raw_message: "",
        timestamp: 1_713_456_789
      }

      assert {:ok, request} = Parser.parse(event)
      assert request.name == "cmd"
      assert request.raw_args == "arg1  arg2"
    end

    test "parses /cmd followed by @user mention as extra segment" do
      event = %GroupMessageEvent{
        group_id: 1,
        self_id: @self_id,
        sender_id: 789,
        message_id: 100,
        message: [Message.text("/warn"), Message.at(@other_id)],
        raw_message: "",
        timestamp: 1_713_456_789
      }

      assert {:ok, request} = Parser.parse(event)
      assert request.name == "warn"
      assert request.raw_args == ""
      assert request.extra_segments == [Message.at(@other_id)]
    end

    test "parses /cmd with args followed by @user mention" do
      event = %GroupMessageEvent{
        group_id: 1,
        self_id: @self_id,
        sender_id: 789,
        message_id: 100,
        message: [Message.text("/warn spam"), Message.at(@other_id)],
        raw_message: "",
        timestamp: 1_713_456_789
      }

      assert {:ok, request} = Parser.parse(event)
      assert request.name == "warn"
      assert request.raw_args == "spam"
      assert request.extra_segments == [Message.at(@other_id)]
    end

    test "parses /cmd with reply, @bot mention, and trailing @user" do
      event = %GroupMessageEvent{
        group_id: 1,
        self_id: @self_id,
        sender_id: 789,
        message_id: 100,
        message: [
          Message.reply("5"),
          Message.at(@self_id),
          Message.text("/warn"),
          Message.at(@other_id)
        ],
        raw_message: "",
        timestamp: 1_713_456_789
      }

      assert {:ok, request} = Parser.parse(event)
      assert request.name == "warn"
      assert request.reply == %{message_id: "5"}
      assert request.mentions_bot? == true
      assert request.raw_args == ""
      assert request.extra_segments == [Message.at(@other_id)]
    end

    test "empty extra_segments when no trailing segments" do
      event = %GroupMessageEvent{
        group_id: 1,
        self_id: @self_id,
        sender_id: 789,
        message_id: 100,
        message: [Message.text("/cmd")],
        raw_message: "/cmd",
        timestamp: 1_713_456_789
      }

      assert {:ok, request} = Parser.parse(event)
      assert request.extra_segments == []
    end
  end
end
