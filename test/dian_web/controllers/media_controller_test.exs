defmodule DianWeb.MediaControllerTest do
  use DianWeb.ConnCase, async: false

  setup do
    Application.put_env(:dian, Dian.Media.ImageStore, store_impl: Dian.Media.ImageStore.Mock)

    on_exit(fn ->
      Application.delete_env(:dian, Dian.Media.ImageStore)
    end)

    :ok
  end

  describe "GET /media/images/:id" do
    test "serves stored image with cache headers", %{conn: conn} do
      asset = %Dian.Media.ImageAsset{
        id: 1,
        object_id: "abc123",
        content_type: "image/png",
        s3_key: "images/abc123.png"
      }

      Mox.expect(Dian.Media.ImageStore.Mock, :get_image, fn "abc123" ->
        {:ok, asset}
      end)

      Mox.expect(Dian.Media.ImageStore.Mock, :get_image_bytes, fn ^asset ->
        {:ok, <<137, 80, 78, 71>>}
      end)

      conn = get(conn, ~p"/media/images/abc123")

      assert conn.status == 200
      assert get_resp_header(conn, "cache-control") == ["public, max-age=31536000, immutable"]
      assert get_resp_header(conn, "etag") == ["\"abc123\""]
      assert conn.resp_body == <<137, 80, 78, 71>>

      Mox.verify!()
    end

    test "returns 404 for unknown hash", %{conn: conn} do
      Mox.expect(Dian.Media.ImageStore.Mock, :get_image, fn "unknown" ->
        {:error, :not_found}
      end)

      conn = get(conn, ~p"/media/images/unknown")
      assert conn.status == 404

      Mox.verify!()
    end

    test "returns 404 when S3 fetch fails", %{conn: conn} do
      asset = %Dian.Media.ImageAsset{
        id: 1,
        object_id: "broken",
        content_type: "image/jpeg",
        s3_key: "images/broken.jpg"
      }

      Mox.expect(Dian.Media.ImageStore.Mock, :get_image, fn "broken" ->
        {:ok, asset}
      end)

      Mox.expect(Dian.Media.ImageStore.Mock, :get_image_bytes, fn ^asset ->
        {:error, :not_found}
      end)

      conn = get(conn, ~p"/media/images/broken")
      assert conn.status == 404

      Mox.verify!()
    end
  end
end
