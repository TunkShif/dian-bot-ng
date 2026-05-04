defmodule Dian.Steam.SteamPlayer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "steam_players" do
    field :steam_id, :string
    field :qq_id, :string
    field :display_name, :string

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creating or updating a steam player binding.
  """
  def changeset(steam_player, attrs) do
    steam_player
    |> cast(attrs, [:steam_id, :qq_id, :display_name])
    |> validate_required([:steam_id, :qq_id])
    |> validate_length(:steam_id, is: 17, message: "must be 17 characters")
    |> validate_format(:steam_id, ~r/^7656\d{13}$/, message: "must be a valid Steam ID")
    |> validate_length(:qq_id, min: 5, max: 13, message: "must be 5-13 digits")
    |> validate_format(:qq_id, ~r/^\d{5,13}$/, message: "must be a valid QQ ID")
    |> unique_constraint(:steam_id)
    |> unique_constraint(:qq_id)
  end
end
