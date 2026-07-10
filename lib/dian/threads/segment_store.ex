defmodule Dian.Threads.SegmentStore do
  @moduledoc """
  Processes raw OneBot message segments for thread storage.

  Each segment type has a handler that returns the segment's type string and
  the (possibly modified) segment. The `process_segments/1` function iterates
  all segments in a message, dispatches each to the correct handler, and
  returns the aggregated result.
  """

  @doc """
  Returns `{type_string, modified_segment}` for a given OneBot segment.
  """
  @callback store(map()) :: {String.t(), map()}

  @doc """
  Processes a list of OneBot segments into a map suitable for message creation.

  Returns `%{segments: [map()], types: [String.t()], text_content: String.t() | nil}`.
  """
  def process_segments(segments) when is_list(segments) do
    initial = %{processed: [], types: [], text_parts: []}

    result =
      Enum.reduce(segments, initial, fn segment, acc ->
        normalized = normalize_segment(segment)
        type = Map.get(normalized, :type, "")
        handler = handler_for(type)

        {returned_type, processed_segment} = handler.store(normalized)

        text =
          if returned_type == "text" do
            [processed_segment[:data]["text"] | acc.text_parts]
          else
            acc.text_parts
          end

        %{
          acc
          | processed: [processed_segment | acc.processed],
            types: [returned_type | acc.types],
            text_parts: text
        }
      end)

    text_content =
      case result.text_parts |> Enum.reverse() |> Enum.join(" ") do
        "" -> nil
        text -> text
      end

    %{
      segments: Enum.reverse(result.processed),
      types: Enum.reverse(result.types),
      text_content: text_content
    }
  end

  defp normalize_segment(segment) do
    type = Map.get(segment, "type") || Map.get(segment, :type) || ""
    data = Map.get(segment, "data") || Map.get(segment, :data) || %{}
    %{type: type, data: data}
  end

  defp handler_for("text"), do: Dian.Threads.SegmentStore.Text
  defp handler_for("image"), do: Dian.Threads.SegmentStore.Image
  defp handler_for(_), do: Dian.Threads.SegmentStore.Fallback
end
