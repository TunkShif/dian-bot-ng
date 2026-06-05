defmodule Dian.ThreadsTest do
  use Dian.DataCase

  alias Dian.Threads.Message
  alias Dian.Threads.Thread

  describe "create_thread_with_messages/2" do
    test "creates thread with single message" do
      assert {:ok, %{thread: thread, messages: [msg]}} =
               Dian.Threads.create_thread_with_messages(
                 %{group_id: "100", creator_id: "200"},
                 [
                   %{
                     raw_message_id: "1",
                     sender_id: "200",
                     segments: [%{type: "text", data: %{"text" => "hello"}}],
                     types: ["text"],
                     text_content: "hello"
                   }
                 ]
               )

      assert thread.group_id == "100"
      assert thread.creator_id == "200"
      assert msg.raw_message_id == "1"
      assert msg.sender_id == "200"
      assert msg.segments == [%{type: "text", data: %{"text" => "hello"}}]
      assert msg.types == ["text"]
      assert msg.text_content == "hello"
    end

    test "creates thread with multiple messages" do
      assert {:ok, %{thread: thread, messages: messages}} =
               Dian.Threads.create_thread_with_messages(
                 %{group_id: "100", creator_id: "200"},
                 [
                   %{
                     raw_message_id: "1",
                     sender_id: "200",
                     segments: [%{type: "text", data: %{"text" => "first"}}],
                     types: ["text"],
                     text_content: "first"
                   },
                   %{
                     raw_message_id: "2",
                     sender_id: "300",
                     segments: [%{type: "image", data: %{"file" => "x.jpg"}}],
                     types: ["image"],
                     text_content: nil
                   }
                 ]
               )

      assert length(messages) == 2
      assert thread.group_id == "100"

      [first, second] = messages
      assert first.raw_message_id == "1"
      assert first.text_content == "first"
      assert second.raw_message_id == "2"
      assert second.types == ["image"]
    end

    test "raises on invalid attrs" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Dian.Threads.create_thread_with_messages(%{}, [])
      end
    end
  end

  describe "save_replied_message/3" do
    setup do
      Cachex.clear(:dian_cache)
      :ok
    end

    test "saves replied message into a new thread" do
      Mox.expect(DianBot.Client.Mock, :request, fn
        "get_msg", %{message_id: "123"}, [] ->
          {:ok,
           %{
             "message" => [%{"type" => "text", "data" => %{"text" => "hello"}}],
             "sender" => %{"user_id" => 1_395_084_414}
           }}
      end)

      assert {:ok, %{thread: %Thread{}, messages: [%Message{}]}} =
               Dian.Threads.save_replied_message("100", "200", "123")

      Mox.verify!()
    end

    test "dedupes concurrent save of the same message" do
      Mox.expect(DianBot.Client.Mock, :request, 1, fn
        "get_msg", %{message_id: "123"}, [] ->
          {:ok,
           %{
             "message" => [%{"type" => "text", "data" => %{"text" => "hello"}}],
             "sender" => %{"user_id" => 1_395_084_414}
           }}
      end)

      assert {:ok, _result} = Dian.Threads.save_replied_message("100", "200", "123")

      assert {:error, :duplicate} =
               Dian.Threads.save_replied_message("100", "300", "123")

      Mox.verify!()
    end

    test "allows same message in different groups" do
      Mox.expect(DianBot.Client.Mock, :request, 2, fn
        "get_msg", %{message_id: "123"}, [] ->
          {:ok,
           %{
             "message" => [%{"type" => "text", "data" => %{"text" => "hello"}}],
             "sender" => %{"user_id" => 1_395_084_414}
           }}
      end)

      assert {:ok, _result} = Dian.Threads.save_replied_message("100", "200", "123")
      assert {:ok, _result} = Dian.Threads.save_replied_message("200", "200", "123")

      Mox.verify!()
    end

    test "returns fetch_failed when get_msg fails" do
      Mox.expect(DianBot.Client.Mock, :request, fn
        "get_msg", %{message_id: "bad"}, [] ->
          {:error, :disconnected}
      end)

      assert {:error, :fetch_failed} =
               Dian.Threads.save_replied_message("100", "200", "bad")

      Mox.verify!()
    end
  end

  describe "collect_message/1" do
    test "processes replied message into msg_attrs" do
      Mox.expect(DianBot.Client.Mock, :request, fn
        "get_msg", %{message_id: "456"}, [] ->
          {:ok,
           %{
             "message" => [%{"type" => "text", "data" => %{"text" => "hi"}}],
             "sender" => %{"user_id" => 1_395_084_414}
           }}
      end)

      assert {:ok, msg_attrs} = Dian.Threads.collect_message("456")
      assert msg_attrs.raw_message_id == "456"
      assert msg_attrs.sender_id == "1395084414"
      assert msg_attrs.types == ["text"]
      assert msg_attrs.text_content == "hi"

      Mox.verify!()
    end

    test "returns fetch_failed on error" do
      Mox.expect(DianBot.Client.Mock, :request, fn
        "get_msg", %{message_id: "bad"}, [] ->
          {:error, :timeout}
      end)

      assert {:error, :fetch_failed} = Dian.Threads.collect_message("bad")

      Mox.verify!()
    end
  end

  describe "batch_save_messages/3" do
    test "persists collected messages as a thread" do
      collected = [
        %{
          raw_message_id: "1",
          sender_id: "200",
          segments: [%{type: "text", data: %{"text" => "a"}}],
          types: ["text"],
          text_content: "a"
        },
        %{
          raw_message_id: "2",
          sender_id: "300",
          segments: [%{type: "image", data: %{"file" => "y.jpg"}}],
          types: ["image"],
          text_content: nil
        }
      ]

      assert {:ok, %{messages: messages}} =
               Dian.Threads.batch_save_messages("100", "200", collected)

      assert length(messages) == 2
    end
  end
end
