defmodule Dian.Repo.Migrations.CreateNotificationMessages do
  use Ecto.Migration

  def change do
    create table(:notification_messages) do
      add :template, :text
      add :operator_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:notification_messages, [:operator_id])
  end
end
