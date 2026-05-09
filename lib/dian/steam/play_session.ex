defmodule Dian.Steam.PlaySession do
  use Ecto.Schema
  import Ecto.Changeset

  schema "steam_play_sessions" do
    field :qq_id, :string
    field :steam_id, :string
    field :app_id, :string
    field :game_name, :string
    field :player_display_name, :string
    field :started_at, :utc_datetime
    field :ended_at, :utc_datetime
    field :duration_seconds, :integer

    field :session_end_reason, Ecto.Enum, values: [:stopped, :switched, :poll_gap]

    timestamps(type: :utc_datetime)
  end

  def changeset(play_session, attrs) do
    play_session
    |> cast(attrs, [
      :qq_id,
      :steam_id,
      :app_id,
      :game_name,
      :player_display_name,
      :started_at,
      :ended_at,
      :duration_seconds,
      :session_end_reason
    ])
    |> validate_required([
      :qq_id,
      :steam_id,
      :app_id,
      :started_at,
      :ended_at,
      :duration_seconds,
      :session_end_reason
    ])
    |> validate_number(:duration_seconds, greater_than_or_equal_to: 0)
  end
end
