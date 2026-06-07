defmodule Dian.Repo.Migrations.CreateImageAssets do
  use Ecto.Migration

  def change do
    create table(:image_assets) do
      add :object_id, :string, null: false
      add :s3_key, :string, null: false
      add :content_type, :string, null: false
      add :width, :integer
      add :height, :integer
      add :original_url, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:image_assets, [:object_id])
    create unique_index(:image_assets, [:s3_key])
  end
end
