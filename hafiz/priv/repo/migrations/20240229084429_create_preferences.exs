defmodule Dian.Repo.Migrations.CreatePreferences do
  use Ecto.Migration

  def change do
    create table(:preferences) do
      add :key, :text
      add :value, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:preferences, [:key])
  end
end
