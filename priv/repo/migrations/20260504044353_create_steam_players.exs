defmodule Dian.Repo.Migrations.CreateSteamPlayers do
  use Ecto.Migration

  def change do
    create table(:steam_players) do
      add :steam_id, :string, null: false
      add :qq_id, :string, null: false
      add :display_name, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:steam_players, [:steam_id])
    create unique_index(:steam_players, [:qq_id])
  end
end
