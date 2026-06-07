defmodule Dian.Media.ImageStore.DefaultTest do
  use Dian.DataCase, async: false

  alias Dian.Media.ImageAsset
  alias Dian.Media.ImageStore.Default

  setup do
    Req.Test.verify_on_exit!()

    Application.put_env(:dian, Dian.Media.ImageStore.Default,
      aws_client: fn _op -> {:ok, %{status_code: 200}} end,
      req_options: [plug: {Req.Test, Dian.Media.ImageStore.Default}]
    )

    on_exit(fn ->
      Application.delete_env(:dian, Dian.Media.ImageStore.Default)
    end)

    :ok
  end

  describe "store_image/3" do
    test "creates asset on first store" do
      image_bytes =
        <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8,
          2, 0, 0, 0, 144, 119, 83, 222, 0, 0, 0, 12, 73, 68, 65, 84, 8, 215, 99, 248, 207, 192,
          0, 0, 0, 3, 0, 1, 0, 24, 221, 141, 0, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130>>

      Req.Test.expect(Dian.Media.ImageStore.Default, fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("image/png")
        |> Plug.Conn.resp(200, image_bytes)
      end)

      assert {:ok, %ImageAsset{} = asset} =
               Default.store_image("test.png", "100", "https://example.com/test.png")

      assert asset.content_type == "image/png"
      assert asset.width == 1
      assert asset.height == 1
      assert asset.original_url == "https://example.com/test.png"
      assert String.starts_with?(asset.s3_key, "images/")
    end

    test "returns existing asset on dedup hit" do
      Req.Test.expect(Dian.Media.ImageStore.Default, fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("image/jpeg")
        |> Plug.Conn.resp(200, <<255, 216, 255, 224>>)
      end)

      {:ok, first} = Default.store_image("dup.jpg", "500", "https://example.com/dup.jpg")
      {:ok, second} = Default.store_image("dup.jpg", "500", "https://example.com/other.jpg")

      assert first.id == second.id
      assert first.object_id == second.object_id
    end

    test "returns download_failed for non-200 response" do
      Req.Test.expect(Dian.Media.ImageStore.Default, fn conn ->
        Plug.Conn.resp(conn, 404, "not found")
      end)

      assert {:error, :download_failed} =
               Default.store_image("missing.jpg", "100", "https://example.com/missing.jpg")
    end
  end

  describe "get_image/1" do
    test "returns asset by object_id" do
      Req.Test.expect(Dian.Media.ImageStore.Default, fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("image/png")
        |> Plug.Conn.resp(200, <<137, 80, 78, 71>>)
      end)

      {:ok, stored} = Default.store_image("find.png", "200", "https://example.com/find.png")
      assert {:ok, found} = Default.get_image(stored.object_id)
      assert found.id == stored.id
    end

    test "returns not_found for unknown object_id" do
      assert {:error, :not_found} = Default.get_image("nonexistent")
    end
  end
end
