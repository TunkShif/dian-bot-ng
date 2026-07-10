defmodule Dian.Media.ImageAsset do
  use Ecto.Schema
  import Ecto.Changeset

  schema "image_assets" do
    field :object_id, :string
    field :s3_key, :string
    field :content_type, :string
    field :width, :integer
    field :height, :integer
    field :original_url, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(image_asset, attrs) do
    image_asset
    |> cast(attrs, [:object_id, :s3_key, :content_type, :width, :height, :original_url])
    |> validate_required([:object_id, :s3_key, :content_type])
    |> unique_constraint(:object_id)
    |> unique_constraint(:s3_key)
  end
end
