defmodule Dian.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :raw_text, :text, null: false, default: ""
      add :content, {:array, :map}, null: false
      add :sender_id, references(:users, on_delete: :nothing), null: false
      add :sent_at, :naive_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:sender_id])
  end
end
