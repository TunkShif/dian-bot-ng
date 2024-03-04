defmodule Dian.Chats.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "images" do
    field :name, :string
    field :url, :string
    field :width, :integer
    field :height, :integer
    field :blurred_data, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:name, :url, :width, :height, :blurred_data])
    |> validate_required([:name, :url, :width, :height, :blurred_data])
    |> unique_constraint([:name])
  end
end
