defmodule Dian.Repo.Migrations.CreatePinnedMessages do
  use Ecto.Migration

  def change do
    create table(:pinned_messages) do
      add :type, :text
      add :content, :text
      add :operator_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:pinned_messages, [:operator_id])
  end
end
