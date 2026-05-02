defmodule Dian.Settings.GlobalSetting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "global_settings" do
    field :superadmin_user_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(global_setting, attrs) do
    global_setting
    |> cast(attrs, [:superadmin_user_id])
    |> validate_required([:superadmin_user_id])
  end
end
