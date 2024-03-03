defmodule Dian.Tracker.Activity do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dian.Chats.User

  schema "activities" do
    field :location, :string
    field :mouse_x, :float
    field :mouse_y, :float
    field :offline_at, :naive_datetime

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(activity, attrs) do
    activity
    |> cast(attrs, [:location, :mouse_x, :mouse_y, :offline_at])
    |> validate_required([:location, :mouse_x, :mouse_y, :offline_at, :user_id])
    |> unique_constraint([:user_id])
  end
end
