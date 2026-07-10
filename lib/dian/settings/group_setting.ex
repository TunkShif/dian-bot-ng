defmodule Dian.Settings.GroupSetting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "group_settings" do
    field :group_id, :string
    field :enabled, :boolean, default: false
    field :steam_status_enabled, :boolean, default: false
    field :steam_achievements_enabled, :boolean, default: false
    field :daily_steam_summary_enabled, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(group_setting, attrs) do
    group_setting
    |> cast(attrs, [
      :group_id,
      :enabled,
      :steam_status_enabled,
      :steam_achievements_enabled,
      :daily_steam_summary_enabled
    ])
    |> validate_required([:group_id, :enabled])
  end
end
