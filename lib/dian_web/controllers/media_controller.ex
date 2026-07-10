defmodule DianWeb.MediaController do
  use DianWeb, :controller

  alias Dian.Media

  def show(conn, %{"id" => object_id}) do
    case Media.get_image(object_id) do
      {:ok, asset} ->
        case Dian.Media.ImageStore.get_image_bytes(asset) do
          {:ok, bytes} ->
            conn
            |> put_resp_content_type(asset.content_type)
            |> put_resp_header("cache-control", "public, max-age=31536000, immutable")
            |> put_resp_header("etag", "\"#{asset.object_id}\"")
            |> send_resp(200, bytes)

          {:error, _reason} ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "asset not available"})
        end

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "asset not found"})
    end
  end
end
