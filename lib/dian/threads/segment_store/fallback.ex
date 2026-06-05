defmodule Dian.Threads.SegmentStore.Fallback do
  @behaviour Dian.Threads.SegmentStore

  @impl true
  def store(segment) do
    type = Map.get(segment, :type, "unknown")
    {type, segment}
  end
end
