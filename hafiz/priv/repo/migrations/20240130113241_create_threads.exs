defmodule Dian.Repo.Migrations.CreateThreads do
  use Ecto.Migration

  def change do
    create table(:threads) do
      add :posted_at, :naive_datetime, null: false
      add :owner_id, references(:users, on_delete: :nothing), null: false
      add :group_id, references(:groups, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:threads, [:owner_id])
    create index(:threads, [:group_id])
  end
end
