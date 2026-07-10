defmodule Dian.Repo.Migrations.CreateThreadsAndMessages do
  use Ecto.Migration

  def change do
    create table(:threads) do
      add :group_id, :string, null: false
      add :creator_id, :string, null: false

      timestamps()
    end

    create table(:messages) do
      add :thread_id, references(:threads, on_delete: :delete_all), null: false
      add :raw_message_id, :string, null: false
      add :sender_id, :string, null: false
      add :segments, {:array, :map}, null: false
      add :types, {:array, :string}, null: false
      add :text_content, :string

      timestamps()
    end

    create index(:threads, [:group_id])
    create index(:messages, [:thread_id])
  end
end
