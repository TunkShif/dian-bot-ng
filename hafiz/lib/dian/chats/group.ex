defmodule Dian.Chats.Group do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dian.Chats.Thread
  alias DianBot.Schemas.Group, as: BotGroup

  schema "groups" do
    field :gid, :string
    field :name, :string
    field :description, :string

    has_many :threads, Thread

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:gid, :name, :description])
    |> validate_required([:gid, :name])
    |> unique_constraint(:gid)
  end

  @spec create_changeset(Ecto.Schema.t(), BotGroup.t()) :: Ecto.Changeset.t()
  def create_changeset(group, %BotGroup{} = group_params) do
    changeset(group, Map.from_struct(group_params))
  end
end
