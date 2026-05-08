defmodule Dian.Steam.AchievementSnapshot do
  use Ecto.Schema
  import Ecto.Changeset

  schema "steam_achievement_snapshots" do
    field :steam_id, :string
    field :qq_id, :string
    field :app_id, :string
    field :game_name, :string
    field :unlocked_achievements, :map, default: %{}

    field :completion_state, Ecto.Enum,
      values: [:active, :fully_unlocked, :no_stats, :private_or_unavailable],
      default: :active

    field :last_checked_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  def changeset(snapshot, attrs) do
    snapshot
    |> cast(attrs, [
      :steam_id,
      :qq_id,
      :app_id,
      :game_name,
      :unlocked_achievements,
      :completion_state,
      :last_checked_at
    ])
    |> validate_required([:steam_id, :qq_id, :app_id, :unlocked_achievements, :completion_state])
    |> unique_constraint([:steam_id, :app_id],
      name: :steam_achievement_snapshots_steam_id_app_id_index
    )
  end
end
