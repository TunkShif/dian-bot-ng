defmodule DianBot.Schemas.MessageTest do
  use Dian.DataCase, async: true

  import Dian.Fixtures

  alias DianBot.BotError
  alias DianBot.Schemas.Message

  describe "Message.prepare/1" do
    test "should process simple message" do
      message = fixture(:message)
      assert {:ok, [message]} = Message.prepare(message)
      assert message.raw_text =~ "hello"
    end

    test "should process forwarded message" do
      message = fixture(:message, raw_text: "[CQ:forward,id=3]")
      assert {:ok, messages} = Message.prepare(message)
      assert length(messages) == 2
    end

    test "should fail when message is not found" do
      message = fixture(:message, raw_text: "[CQ:forward,id=999]")
      assert {:error, %BotError{message: "not found"}} = Message.prepare(message)
    end

    test "should process at cq code" do
      message = fixture(:message, raw_text: "[CQ:at,qq=3]hello")
      assert {:ok, [message]} = Message.prepare(message)
      assert length(message.content) == 2
      assert [%{type: "at", data: %{qid: "3"}}, %{type: "text", data: "hello"}] = message.content
      assert Repo.get_by(Dian.Chats.User, qid: "3")
    end
  end
end
