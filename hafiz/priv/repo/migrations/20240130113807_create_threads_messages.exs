defmodule Dian.Repo.Migrations.CreateThreadsMessages do
  use Ecto.Migration

  def change do
    create table(:threads_messages, primary_key: false) do
      add :thread_id, references(:threads, on_delete: :delete_all), primary_key: true, null: false

      add :message_id, references(:messages, on_delete: :delete_all),
        primary_key: true,
        null: false

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:threads_messages, [:thread_id])
    create index(:threads_messages, [:message_id])
  end
end
