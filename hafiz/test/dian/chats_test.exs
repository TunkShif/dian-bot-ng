defmodule Dian.ChatsTest do
  use Dian.DataCase, async: true

  import Dian.Fixtures

  alias Dian.Chats
  alias Dian.Chats.Thread

  describe "Chats.create_thread/1" do
    test "should create thread when given an valid event" do
      event = fixture(:event, mid: "1", qid: "1", gid: "1")

      assert {:ok, %Thread{} = thread} = Chats.create_thread(event)
      assert thread.owner.qid == "1"
      assert thread.group.gid == "1"
      assert length(thread.messages) == 1
      assert message = hd(thread.messages)
      assert length(message.content) == 1
      assert hd(message.content).type == "text"
      assert hd(message.content).data =~ "Hello"
    end

    test "should create thread when given forwarded message" do
      event = fixture(:event, mid: "6")

      assert {:ok, %Thread{} = thread} = Chats.create_thread(event)
      assert length(thread.messages) == 3
    end
  end
end
