defmodule Dian.Media.ImageStore do
  @moduledoc """
  Behaviour and facade for image asset storage backed by S3-compatible storage.

  Downloads images from URLs, detects mime type and dimensions,
  uploads to S3, and serves stored assets through a proxy endpoint.
  Uses filename + file_size hash for deduplication (IM platform guarantees
  same filename+filesize = same file).
  """

  alias Dian.Media.ImageAsset

  @type store_error ::
          :download_failed
          | :upload_failed
          | :not_found
          | {:store_error, term()}

  @callback store_image(String.t(), String.t(), String.t()) ::
              {:ok, ImageAsset.t()} | {:error, store_error()}

  @callback get_image(String.t()) ::
              {:ok, ImageAsset.t()} | {:error, :not_found}

  @callback get_image_bytes(ImageAsset.t()) ::
              {:ok, binary()} | {:error, store_error()}

  @callback delete_image(ImageAsset.t()) :: :ok | {:error, term()}

  @doc """
  Stores an image identified by `filename` and `file_size` from `url`.
  Returns existing asset on dedup hit (skips download).
  """
  def store_image(filename, file_size, url) do
    impl().store_image(filename, file_size, url)
  end

  @doc """
  Fetches an image asset record by its object_id (content hash).
  """
  def get_image(object_id) do
    impl().get_image(object_id)
  end

  @doc """
  Downloads the image bytes from S3 for serving through the proxy.
  """
  def get_image_bytes(%ImageAsset{} = asset) do
    impl().get_image_bytes(asset)
  end

  @doc """
  Deletes an image asset from both S3 and the database.
  """
  def delete_image(%ImageAsset{} = asset) do
    impl().delete_image(asset)
  end

  defp impl do
    Application.get_env(:dian, __MODULE__, [])
    |> Keyword.get(:store_impl, Dian.Media.ImageStore.Default)
  end
end
