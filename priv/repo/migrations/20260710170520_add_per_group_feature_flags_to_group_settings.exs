defmodule Dian.Repo.Migrations.AddPerGroupFeatureFlagsToGroupSettings do
  use Ecto.Migration

  def change do
    alter table(:group_settings) do
      add :steam_status_enabled, :boolean, default: false, null: false
      add :steam_achievements_enabled, :boolean, default: false, null: false
      add :daily_steam_summary_enabled, :boolean, default: false, null: false
    end
  end
end
