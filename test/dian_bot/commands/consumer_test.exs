defmodule DianBot.Commands.ConsumerTest do
  use ExUnit.Case, async: false

  alias DianBot.Commands.Batch
  alias DianBot.Commands.Consumer
  alias DianBot.Event.GroupMessageEvent
  alias DianBot.Message

  # --- Test handler modules ---

  defmodule BasicHandler do
    @behaviour DianBot.Commands.Handler

    def command, do: "test"
    def aliases, do: ["t"]
    def usage, do: "/test <arg>"
    def parse_args(""), do: {:error, "arg required"}
    def parse_args(args), do: {:ok, args}
    def handle(_request, args), do: {:reply, "got: #{args}"}
  end

  defmodule MentionHandler do
    @behaviour DianBot.Commands.Handler

    def command, do: "mention_cmd"
    def aliases, do: []
    def usage, do: "/mention_cmd"
    def parse_args(args), do: {:ok, args}
    def handle(_request, _args), do: {:reply, "mentioned!"}
  end

  defmodule ReplyHandler do
    @behaviour DianBot.Commands.Handler

    def command, do: "reply_cmd"
    def aliases, do: []
    def usage, do: "/reply_cmd"
    def parse_args(args), do: {:ok, args}
    def handle(_request, _args), do: {:reply, "replied!"}
  end

  defmodule CrashHandler do
    @behaviour DianBot.Commands.Handler

    def command, do: "crash_cmd"
    def aliases, do: []
    def usage, do: "/crash_cmd"
    def parse_args(args), do: {:ok, args}
    def handle(_request, _args), do: raise("boom")
  end

  # --- Test workflow module ---

  defmodule BatchHandler do
    @behaviour DianBot.Commands.BatchWorkflow

    def workflow, do: :consumer_batch_test
    def timeout_ms, do: :timer.hours(1)
    def parse_args(args), do: {:ok, args}

    def scope(request) do
      %{group_id: request.group_id, sender_id: request.sender_id}
    end

    def collect(_request, args), do: {:ok, args}

    def flush(_scope, entries, _reason) do
      {:reply, "flushed: #{length(entries)} entries"}
    end
  end

  # --- Setup ---

  setup do
    test_pid = self()

    send_msg = fn :group, group_id, msg ->
      send(test_pid, {:send_msg, group_id, msg})
    end

    alias DianBot.Commands.Registry.Entry

    lookup = fn
      "test" ->
        {:ok, %Entry{type: :immediate, module: BasicHandler, mention_required?: false, reply_required?: false, usage: "/test <arg>", throttle: :none}}

      "t" ->
        {:ok, %Entry{type: :immediate, module: BasicHandler, mention_required?: false, reply_required?: false, usage: "/test <arg>", throttle: :none}}

      "mention_cmd" ->
        {:ok, %Entry{type: :immediate, module: MentionHandler, mention_required?: true, reply_required?: false, usage: "/mention_cmd", throttle: :none}}

      "reply_cmd" ->
        {:ok, %Entry{type: :immediate, module: ReplyHandler, mention_required?: false, reply_required?: true, usage: "/reply_cmd", throttle: :none}}

      "crash_cmd" ->
        {:ok, %Entry{type: :immediate, module: CrashHandler, mention_required?: false, reply_required?: false, usage: "/crash_cmd", throttle: :none}}

      "append" ->
        {:ok, %Entry{type: :batch_collect, module: BatchHandler, mention_required?: false, reply_required?: false, usage: "/append <key>", throttle: :none}}

      "submit" ->
        {:ok, %Entry{type: :batch_flush, module: BatchHandler, mention_required?: false, reply_required?: false, usage: "/submit", throttle: :none}}

      _ -> :error
    end

    start_supervised!({Batch, send_msg: fn _, _, _ -> :ok end})
    start_supervised!({Consumer, subscribe?: false, send_msg: send_msg, lookup: lookup})
    :ok
  end

  defp event(text, opts \\ []) do
    %GroupMessageEvent{
      self_id: Keyword.get(opts, :self_id, 123),
      group_id: Keyword.get(opts, :group_id, 1),
      sender_id: Keyword.get(opts, :sender_id, 789),
      message_id: 100,
      message: [Message.text(text)],
      raw_message: text,
      timestamp: 1_713_456_789
    }
  end

  # --- Tests ---

  describe "immediate command handling" do
    test "unknown command is ignored" do
      consumer = Process.whereis(Consumer)
      send(consumer, event("/unknown_cmd"))
      refute_receive {:send_msg, _, _}
    end

    test "valid command receives parsed args and sends reply" do
      consumer = Process.whereis(Consumer)
      send(consumer, event("/test hello"))
      assert_receive {:send_msg, 1, "got: hello"}, 500
    end

    test "command alias works" do
      consumer = Process.whereis(Consumer)
      send(consumer, event("/t alias_test"))
      assert_receive {:send_msg, 1, "got: alias_test"}, 500
    end

    test "mention-required command with no mention is silently ignored" do
      consumer = Process.whereis(Consumer)
      send(consumer, event("/mention_cmd"))
      refute_receive {:send_msg, _, _}
    end

    test "mention-required command with mention succeeds" do
      consumer = Process.whereis(Consumer)

      event = %GroupMessageEvent{
        self_id: 123,
        group_id: 1,
        sender_id: 789,
        message_id: 100,
        message: [Message.at(123), Message.text("/mention_cmd")],
        raw_message: "",
        timestamp: 1_713_456_789
      }

      send(consumer, event)
      assert_receive {:send_msg, 1, "mentioned!"}, 500
    end

    test "reply-required command with no reply sends usage" do
      consumer = Process.whereis(Consumer)
      send(consumer, event("/reply_cmd"))
      assert_receive {:send_msg, 1, "/reply_cmd: a replied message is required"}, 500
    end

    test "invalid args send usage" do
      consumer = Process.whereis(Consumer)
      send(consumer, event("/test"))
      assert_receive {:send_msg, 1, "/test <arg>: arg required"}, 500
    end
  end

  describe "handler exceptions" do
    test "exception does not crash the consumer" do
      consumer = Process.whereis(Consumer)

      send(consumer, event("/crash_cmd arg"))
      assert_receive {:send_msg, 1, "Error: command failed"}, 500

      send(consumer, event("/test still_alive"))
      assert_receive {:send_msg, 1, "got: still_alive"}, 500
    end
  end

  describe "batch command handling" do
    test "collect stores entry and flush sends reply" do
      consumer = Process.whereis(Consumer)

      send(consumer, event("/append key1"))
      send(consumer, event("/submit"))
      assert_receive {:send_msg, 1, "flushed: 1 entries"}, 500
    end
  end
end
