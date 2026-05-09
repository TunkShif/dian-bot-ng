defmodule Dian.Repo.Migrations.CreateSteamPlaySessions do
  use Ecto.Migration

  def change do
    create table(:steam_play_sessions) do
      add :qq_id, :string, null: false
      add :steam_id, :string, null: false
      add :app_id, :string, null: false
      add :game_name, :string
      add :player_display_name, :string
      add :started_at, :utc_datetime, null: false
      add :ended_at, :utc_datetime, null: false
      add :duration_seconds, :integer, null: false
      add :session_end_reason, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:steam_play_sessions, [:qq_id, :started_at])
    create index(:steam_play_sessions, [:steam_id, :started_at])
    create index(:steam_play_sessions, [:app_id, :started_at])
  end
end
