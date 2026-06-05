defmodule Dian.Threads.SegmentStore.Text do
  @behaviour Dian.Threads.SegmentStore

  @impl true
  def store(%{type: "text"} = segment) do
    {"text", segment}
  end
end
