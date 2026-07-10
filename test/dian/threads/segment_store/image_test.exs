defmodule Dian.Threads.SegmentStore.ImageTest do
  use Dian.DataCase, async: false

  alias Dian.Threads.SegmentStore.Image

  setup do
    Application.put_env(:dian, Dian.Media.ImageStore, store_impl: Dian.Media.ImageStore.Mock)

    on_exit(fn ->
      Application.delete_env(:dian, Dian.Media.ImageStore)
    end)

    :ok
  end

  test "downloads image and rewrites segment URLs" do
    Mox.expect(Dian.Media.ImageStore.Mock, :store_image, fn filename, file_size, url ->
      assert filename == "photo.jpg"
      assert file_size == "1234"
      assert url == "https://cdn.example/photo.jpg"

      {:ok,
       %Dian.Media.ImageAsset{
         id: 1,
         object_id: "abc123def456",
         content_type: "image/jpeg",
         s3_key: "images/abc123def456.jpg"
       }}
    end)

    segment = %{
      type: "image",
      data: %{
        "file" => "photo.jpg",
        "file_size" => "1234",
        "url" => "https://cdn.example/photo.jpg"
      }
    }

    assert {"image", result} = Image.store(segment)
    assert result.data["url"] =~ "/media/images/abc123def456"
    assert result.data["file"] =~ "/media/images/abc123def456"
    assert result.data["original_url"] == "https://cdn.example/photo.jpg"

    Mox.verify!()
  end

  test "falls back to original segment on storage failure" do
    Mox.expect(Dian.Media.ImageStore.Mock, :store_image, fn _f, _s, _u ->
      {:error, :download_failed}
    end)

    segment = %{
      type: "image",
      data: %{
        "file" => "photo.jpg",
        "file_size" => "1234",
        "url" => "https://cdn.example/photo.jpg"
      }
    }

    assert {"image", result} = Image.store(segment)
    assert result == segment

    Mox.verify!()
  end

  test "falls back when file_size is missing" do
    segment = %{
      type: "image",
      data: %{"file" => "photo.jpg", "url" => "https://cdn.example/photo.jpg"}
    }

    assert {"image", result} = Image.store(segment)
    assert result == segment
  end

  test "falls back when url is missing" do
    segment = %{
      type: "image",
      data: %{"file" => "photo.jpg", "file_size" => "1234"}
    }

    assert {"image", result} = Image.store(segment)
    assert result == segment
  end
end
