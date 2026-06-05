defmodule Dian.Threads.SegmentStore.Image do
  @behaviour Dian.Threads.SegmentStore

  @impl true
  def store(%{type: "image"} = segment) do
    {"image", segment}
  end
end
