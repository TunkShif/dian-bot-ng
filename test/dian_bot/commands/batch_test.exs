defmodule DianBot.Commands.BatchTest do
  use ExUnit.Case, async: false

  alias DianBot.Commands.Batch
  alias DianBot.Commands.CommandRequest

  defmodule RecordingWorkflow do
    @behaviour DianBot.Commands.BatchWorkflow

    def cmds, do: []
    def workflow, do: :recording
    def timeout_ms, do: :timer.hours(1)
    def parse_args(args, _extra_segments), do: {:ok, args}

    def scope(request) do
      %{group_id: request.group_id, sender_id: request.sender_id}
    end

    def collect(_request, args), do: {:ok, args}

    def flush(_scope, entries, reason) do
      Agent.update(:batch_recorder, &[{entries, reason} | &1])
      :noreply
    end
  end

  setup do
    start_supervised!(%{
      id: :batch_recorder,
      start: {Agent, :start_link, [fn -> [] end, [name: :batch_recorder]]}
    })

    start_supervised!({Batch, send_msg: fn _, _, _ -> :ok end})
    :ok
  end

  defp request(group_id, sender_id, opts \\ []) do
    %CommandRequest{
      group_id: group_id,
      sender_id: sender_id,
      message_id: Keyword.get(opts, :message_id, 100),
      timestamp: 1_713_456_789,
      name: Keyword.get(opts, :name, "append"),
      raw_args: Keyword.get(opts, :raw_args, "key"),
      mentions_bot?: false,
      reply: nil,
      event: nil,
      segments: []
    }
  end

  describe "collect/3" do
    test "accumulates entries for the same scope" do
      Batch.collect(RecordingWorkflow, request(1, 100), "entry1")
      Batch.collect(RecordingWorkflow, request(1, 100), "entry2")
      Batch.flush(RecordingWorkflow, request(1, 100))

      flushed = Agent.get(:batch_recorder, & &1)
      {entries, _reason} = hd(flushed)
      assert entries == ["entry1", "entry2"]
    end

    test "scopes entries by group_id and sender_id" do
      Batch.collect(RecordingWorkflow, request(1, 100), "a")
      Batch.collect(RecordingWorkflow, request(2, 200), "b")
      Batch.collect(RecordingWorkflow, request(1, 100), "c")

      Batch.flush(RecordingWorkflow, request(1, 100))
      flushed = Agent.get(:batch_recorder, & &1)
      {entries, _reason} = hd(flushed)
      assert entries == ["a", "c"]

      Batch.flush(RecordingWorkflow, request(2, 200))
      flushed = Agent.get(:batch_recorder, & &1)
      {entries2, _reason} = hd(flushed)
      assert entries2 == ["b"]
    end
  end

  describe "flush/2" do
    test "returns {:error, :no_entries} when nothing to flush" do
      assert Batch.flush(RecordingWorkflow, request(3, 300)) == {:error, :no_entries}
    end

    test "preserves entries for other scopes" do
      Batch.collect(RecordingWorkflow, request(1, 100), "keep_me")
      Batch.collect(RecordingWorkflow, request(2, 200), "flush_me")

      Batch.flush(RecordingWorkflow, request(2, 200))
      flushed = Agent.get(:batch_recorder, & &1)
      assert length(flushed) == 1

      Batch.flush(RecordingWorkflow, request(1, 100))
      flushed = Agent.get(:batch_recorder, & &1)
      assert length(flushed) == 2
    end
  end

  describe "timeout auto-flush" do
    test "direct flush_timeout message triggers flush with reason :timeout" do
      batch_pid = Process.whereis(Batch)

      Batch.collect(RecordingWorkflow, request(1, 100), "to_entry")

      scope = RecordingWorkflow.scope(request(1, 100))
      send(batch_pid, {:flush_timeout, {RecordingWorkflow, scope}})
      :sys.get_state(batch_pid)

      flushed = Agent.get(:batch_recorder, & &1)
      {entries, reason} = hd(flushed)
      assert entries == ["to_entry"]
      assert reason == :timeout
    end
  end
end
