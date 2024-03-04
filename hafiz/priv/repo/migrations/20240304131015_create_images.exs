defmodule Dian.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :name, :text
      add :url, :text
      add :width, :integer
      add :height, :integer
      add :blurred_data, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:images, [:name])
  end
end
