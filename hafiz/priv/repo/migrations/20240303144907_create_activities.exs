defmodule Dian.Repo.Migrations.CreateActivities do
  use Ecto.Migration

  def change do
    create table(:activities) do
      add :location, :text
      add :mouse_x, :float
      add :mouse_y, :float
      add :offline_at, :naive_datetime
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:activities, [:user_id])
  end
end
