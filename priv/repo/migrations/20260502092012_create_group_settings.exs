defmodule Dian.Repo.Migrations.CreateGroupSettings do
  use Ecto.Migration

  def change do
    create table(:group_settings) do
      add :group_id, :string, null: false
      add :enabled, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
