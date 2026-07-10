defmodule Dian.Media.ImageStore.Default do
  @moduledoc false

  @behaviour Dian.Media.ImageStore

  require Logger

  alias Dian.Media.ImageAsset
  alias Dian.Repo

  @impl true
  def store_image(filename, file_size, url)
      when is_binary(filename) and is_binary(file_size) and is_binary(url) do
    object_id = hash_object_id(filename, file_size)

    case Repo.get_by(ImageAsset, object_id: object_id) do
      %ImageAsset{} = existing ->
        {:ok, existing}

      nil ->
        with {:ok, bytes, content_type} <- download(url),
             {:ok, width, height} <- detect_dimensions(bytes),
             s3_key = build_s3_key(object_id, content_type),
             :ok <- upload_to_s3(s3_key, bytes, content_type) do
          %ImageAsset{}
          |> ImageAsset.changeset(%{
            object_id: object_id,
            s3_key: s3_key,
            content_type: content_type,
            width: width,
            height: height,
            original_url: url
          })
          |> Repo.insert()
          |> case do
            {:ok, asset} ->
              {:ok, asset}

            {:error, %{errors: [object_id: _]}} ->
              {:ok, existing} = get_image(object_id)
              {:ok, existing}

            {:error, changeset} ->
              Logger.error("image store: insert failed", errors: inspect(changeset.errors))
              {:error, {:store_error, changeset}}
          end
        end
    end
  end

  @impl true
  def get_image(object_id) when is_binary(object_id) do
    case Repo.get_by(ImageAsset, object_id: object_id) do
      %ImageAsset{} = asset -> {:ok, asset}
      nil -> {:error, :not_found}
    end
  end

  @impl true
  def get_image_bytes(%ImageAsset{s3_key: s3_key}) do
    bucket = config(:bucket)

    case aws_request(ExAws.S3.get_object(bucket, s3_key)) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status_code: status}} ->
        Logger.warning("image store: S3 get failed", s3_key: s3_key, status: status)
        {:error, :not_found}

      {:error, reason} ->
        Logger.error("image store: S3 get error", s3_key: s3_key, reason: inspect(reason))
        {:error, {:store_error, reason}}
    end
  end

  @impl true
  def delete_image(%ImageAsset{s3_key: s3_key} = asset) do
    bucket = config(:bucket)

    with {:ok, _} <- aws_request(ExAws.S3.delete_object(bucket, s3_key)),
         {:ok, _} <- Repo.delete(asset) do
      :ok
    else
      {:error, reason} -> {:error, reason}
    end
  end

  # -- Private --

  defp download(url) do
    req_options =
      [url: url, retry: false, receive_timeout: 10_000]
      |> Keyword.merge(
        Application.get_env(:dian, __MODULE__, [])
        |> Keyword.get(:req_options, [])
      )

    case Req.get(req_options) do
      {:ok, %Req.Response{status: 200, body: body, headers: headers}}
      when is_binary(body) ->
        content_type = detect_content_type(url, headers)
        {:ok, body, content_type}

      {:ok, %Req.Response{status: status}} ->
        Logger.warning("image store: download failed", url: url, status: status)
        {:error, :download_failed}

      {:error, reason} ->
        Logger.warning("image store: download error", url: url, reason: inspect(reason))
        {:error, :download_failed}
    end
  end

  defp detect_content_type(url, headers) do
    headers
    |> Enum.find_value(fn
      {"content-type", value} -> value
      {"Content-Type", value} -> value
      _ -> nil
    end)
    |> normalize_content_type()
    |> fallback_content_type(url)
  end

  defp fallback_content_type(nil, url), do: MIME.from_path(url)
  defp fallback_content_type(content_type, _url), do: content_type

  defp normalize_content_type(nil), do: nil

  defp normalize_content_type(value) when is_list(value),
    do: normalize_content_type(List.first(value))

  defp normalize_content_type(value) when is_binary(value) do
    value |> String.split(";") |> List.first() |> String.trim()
  end

  defp detect_dimensions(bytes) do
    case Image.from_binary(bytes) do
      {:ok, image} ->
        {width, height, _bands} = Image.shape(image)
        {:ok, width, height}

      {:error, reason} ->
        Logger.warning("image store: dimension detection failed", reason: inspect(reason))
        {:ok, nil, nil}
    end
  end

  defp hash_object_id(filename, file_size) do
    :crypto.hash(:sha256, filename <> file_size) |> Base.encode16(case: :lower)
  end

  defp build_s3_key(object_id, content_type) do
    ext = extension_for(content_type)
    "images/#{object_id}#{ext}"
  end

  defp upload_to_s3(s3_key, bytes, content_type) do
    bucket = config(:bucket)

    case aws_request(ExAws.S3.put_object(bucket, s3_key, bytes, content_type: content_type)) do
      {:ok, %{status_code: status}} when status in 200..299 ->
        :ok

      {:ok, %{status_code: status}} ->
        Logger.error("image store: S3 upload failed", s3_key: s3_key, status: status)
        {:error, :upload_failed}

      {:error, reason} ->
        Logger.error("image store: S3 upload error", s3_key: s3_key, reason: inspect(reason))
        {:error, :upload_failed}
    end
  end

  defp aws_request(op) do
    client =
      Application.get_env(:dian, __MODULE__, [])
      |> Keyword.get(:aws_client, &ExAws.request/1)

    client.(op)
  end

  defp extension_for("image/jpeg"), do: ".jpg"
  defp extension_for("image/png"), do: ".png"
  defp extension_for("image/gif"), do: ".gif"
  defp extension_for("image/webp"), do: ".webp"
  defp extension_for("image/svg+xml"), do: ".svg"
  defp extension_for(_), do: ""

  defp config(key, default \\ nil) do
    Application.get_env(:dian, Dian.Media.ImageStore, [])
    |> Keyword.get(key, default)
  end
end
