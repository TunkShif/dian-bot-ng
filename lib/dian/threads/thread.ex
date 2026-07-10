defmodule Dian.Threads.Thread do
  use Ecto.Schema
  import Ecto.Changeset

  schema "threads" do
    field :group_id, :string
    field :creator_id, :string

    has_many :messages, Dian.Threads.Message

    timestamps(type: :utc_datetime)
  end

  def changeset(thread, attrs) do
    thread
    |> cast(attrs, [:group_id, :creator_id])
    |> validate_required([:group_id, :creator_id])
  end
end
