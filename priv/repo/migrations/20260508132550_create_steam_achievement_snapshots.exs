defmodule Dian.Repo.Migrations.CreateSteamAchievementSnapshots do
  use Ecto.Migration

  def change do
    create table(:steam_achievement_snapshots) do
      add :steam_id, :string, null: false
      add :qq_id, :string, null: false
      add :app_id, :string, null: false
      add :game_name, :string
      add :unlocked_achievements, :map, null: false, default: %{}
      add :completion_state, :string, null: false, default: "active"
      add :last_checked_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:steam_achievement_snapshots, [:steam_id, :app_id])
  end
end
