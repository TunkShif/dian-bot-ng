defmodule DianBot.Client.WebSocketTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias DianBot.EventBus

  setup do
    broker = start_supervised!({DianBot.Client.WebSocket, timeout: 10_000})
    %{broker: broker}
  end

  describe "request lifecycle" do
    test "successful request/response correlation by echo", %{broker: broker} do
      connect_fake_transport(broker)

      task =
        Task.async(fn ->
          DianBot.Client.WebSocket.request("get_group_list", %{}, timeout: 5_000)
        end)

      echo = wait_for_pending(broker)

      send(
        broker,
        {:ws_payload,
         %{
           "echo" => echo,
           "status" => "ok",
           "retcode" => 0,
           "data" => %{"groups" => []}
         }}
      )

      assert {:ok, %{"groups" => []}} = Task.await(task, 1_000)
    end

    test "concurrent requests complete independently", %{broker: broker} do
      connect_fake_transport(broker)

      task1 =
        Task.async(fn ->
          DianBot.Client.WebSocket.request("action_1", %{}, timeout: 5_000)
        end)

      task2 =
        Task.async(fn ->
          DianBot.Client.WebSocket.request("action_2", %{}, timeout: 5_000)
        end)

      wait_for_pending_count(broker, 2)

      # Respond to each pending echo with unique data
      state = :sys.get_state(broker)

      for echo <- Map.keys(state.pending) do
        send(
          broker,
          {:ws_payload,
           %{
             "echo" => echo,
             "status" => "ok",
             "retcode" => 0,
             "data" => %{"tag" => echo}
           }}
        )
      end

      r1 = Task.await(task1, 1_000)
      r2 = Task.await(task2, 1_000)
      assert {:ok, _} = r1
      assert {:ok, _} = r2
      assert r1 != r2
    end
  end

  describe "timeout" do
    test "replies once and drops late response", %{broker: broker} do
      connect_fake_transport(broker)

      task =
        Task.async(fn ->
          DianBot.Client.WebSocket.request("action", %{}, timeout: 50)
        end)

      echo = wait_for_pending(broker)
      assert {:error, :timeout} = Task.await(task, 1_000)

      # Verify pending entry cleaned up
      assert %{} = :sys.get_state(broker).pending

      # Simulate a late response — must not crash
      send(
        broker,
        {:ws_payload,
         %{
           "echo" => echo,
           "status" => "ok",
           "retcode" => 0,
           "data" => %{}
         }}
      )

      # Give broker time to process the message
      Process.sleep(10)

      assert %{} = :sys.get_state(broker).pending
    end
  end

  describe "disconnect" do
    test "drains all pending requests", %{broker: broker} do
      connect_fake_transport(broker)

      task1 =
        Task.async(fn ->
          DianBot.Client.WebSocket.request("action_1", %{}, timeout: 10_000)
        end)

      task2 =
        Task.async(fn ->
          DianBot.Client.WebSocket.request("action_2", %{}, timeout: 10_000)
        end)

      wait_for_pending_count(broker, 2)

      send(broker, {:ws_disconnected, :test})

      assert {:error, :disconnected} = Task.await(task1, 1_000)
      assert {:error, :disconnected} = Task.await(task2, 1_000)
      assert %{} = :sys.get_state(broker).pending
      refute :sys.get_state(broker).connected?
    end

    test "double disconnect is a no-op on pending map", %{broker: broker} do
      connect_fake_transport(broker)

      send(broker, {:ws_disconnected, :reason_a})
      Process.sleep(10)

      state = :sys.get_state(broker)
      refute state.connected?
      assert state.transport_pid == nil
      assert state.pending == %{}

      send(broker, {:ws_disconnected, :reason_b})
      Process.sleep(10)

      assert %{} = :sys.get_state(broker).pending
    end
  end

  describe "error paths" do
    test "request while disconnected fails fast", %{broker: _broker} do
      assert {:error, :disconnected} =
               DianBot.Client.WebSocket.request("action", %{}, timeout: 5_000)
    end

    test "malformed payload (invalid echo) does not crash broker", %{broker: broker} do
      connect_fake_transport(broker)

      send(
        broker,
        {:ws_payload,
         %{
           "echo" => "nonexistent-echo",
           "status" => "ok",
           "retcode" => 0
         }}
      )

      Process.sleep(10)
      assert %{} = :sys.get_state(broker).pending
    end

    test "unknown response echo is logged and dropped", %{broker: broker} do
      connect_fake_transport(broker)

      log =
        capture_log(fn ->
          send(
            broker,
            {:ws_payload,
             %{
               "echo" => "unknown-echo",
               "status" => "ok",
               "retcode" => 0
             }}
          )

          Process.sleep(10)
        end)

      assert log =~ "late or unknown response dropped"
    end
  end

  describe "caller death" do
    test "removes pending entry when caller exits", %{broker: broker} do
      connect_fake_transport(broker)

      caller =
        spawn(fn ->
          DianBot.Client.WebSocket.request("action", %{}, timeout: 10_000)
          # This will never return
        end)

      wait_for_pending(broker)

      Process.exit(caller, :kill)

      # Wait for DOWN to be processed
      wait_for_no_pending(broker)

      assert %{} = :sys.get_state(broker).pending
      assert %{} = :sys.get_state(broker).monitors
    end
  end

  describe "event dispatch" do
    test "event payload is broadcast through EventBus", %{broker: broker} do
      connect_fake_transport(broker)
      EventBus.subscribe()

      payload = %{
        "post_type" => "message",
        "message_type" => "group",
        "self_id" => "bot-1",
        "group_id" => "group-1",
        "sender" => %{"user_id" => "user-1"},
        "message_id" => 123,
        "message" => [%{"type" => "text", "data" => %{"text" => "hello"}}],
        "raw_message" => "hello",
        "time" => 1_000_000
      }

      send(broker, {:ws_payload, payload})

      assert_receive %DianBot.Event.GroupMessageEvent{
        group_id: "group-1",
        sender_id: "user-1",
        message: [%{type: "text", data: %{"text" => "hello"}}]
      }
    end
  end

  # Helpers

  defp connect_fake_transport(broker) do
    transport = spawn(fn -> :ok end)
    send(broker, {:ws_connected, transport})
    Process.sleep(5)
  end

  defp wait_for_pending(broker, timeout \\ 1_000) do
    [echo | _] = wait_for_pending_count(broker, 1, timeout)
    echo
  end

  defp wait_for_pending_count(broker, count, timeout \\ 1_000) do
    deadline = System.monotonic_time(:millisecond) + timeout

    state = :sys.get_state(broker)
    keys = Map.keys(state.pending)

    if length(keys) >= count do
      keys
    else
      if System.monotonic_time(:millisecond) < deadline do
        Process.sleep(5)
        wait_for_pending_count(broker, count, timeout)
      else
        flunk("expected #{count} pending entries, got #{length(keys)} within #{timeout}ms")
      end
    end
  end

  defp wait_for_no_pending(broker, timeout \\ 1_000) do
    deadline = System.monotonic_time(:millisecond) + timeout

    state = :sys.get_state(broker)

    if state.pending == %{} do
      :ok
    else
      if System.monotonic_time(:millisecond) < deadline do
        Process.sleep(10)
        wait_for_no_pending(broker, timeout)
      else
        flunk("pending entries were not cleared within #{timeout}ms")
      end
    end
  end
end
