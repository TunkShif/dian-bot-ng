defmodule Dian.Admins.Preference do
  use Ecto.Schema
  import Ecto.Changeset

  schema "preferences" do
    field :value, :string
    field :key, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(preference, attrs) do
    preference
    |> cast(attrs, [:key, :value])
    |> validate_required([:key, :value])
  end
end
