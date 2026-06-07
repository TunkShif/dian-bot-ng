defmodule Dian.Threads.SegmentStore.Image do
  @behaviour Dian.Threads.SegmentStore

  require Logger

  @impl true
  def store(%{type: "image", data: data} = segment) do
    filename = data["file"]
    file_size = data["file_size"]
    url = data["url"]

    case store_image(filename, file_size, url) do
      {:ok, asset} ->
        proxy_url = Dian.Media.get_image_url(asset)

        updated_data =
          Map.merge(data, %{
            "file" => proxy_url,
            "url" => proxy_url,
            "original_url" => url
          })

        {"image", %{segment | data: updated_data}}

      _ ->
        {"image", segment}
    end
  end

  defp store_image(filename, file_size, url)
       when is_binary(filename) and filename != "" and
              is_binary(file_size) and file_size != "" and
              is_binary(url) and url != "" do
    case Dian.Media.store_image(filename, file_size, url) do
      {:ok, asset} ->
        {:ok, asset}

      {:error, reason} ->
        Logger.warning("segment_store: image storage failed",
          filename: filename,
          url: url,
          reason: inspect(reason)
        )

        {:error, reason}
    end
  end

  defp store_image(_filename, _file_size, _url), do: {:error, :invalid_segment}
end
