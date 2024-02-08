defmodule Dian.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :qid, :text, null: false
      add :name, :text, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:qid])
  end
end
