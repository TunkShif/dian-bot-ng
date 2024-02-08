defmodule Dian.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :gid, :text, null: false
      add :name, :text, null: false
      add :description, :text, default: ""

      timestamps(type: :utc_datetime)
    end

    create unique_index(:groups, [:gid])
  end
end
