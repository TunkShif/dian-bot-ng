defmodule Dian.Chats.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dian.Chats.{Thread, Message}
  alias DianBot.Schemas.User, as: BotUser

  schema "users" do
    field :qid, :string
    field :name, :string

    has_many :threads, Thread, foreign_key: :owner_id
    has_many :messages, Message, foreign_key: :sender_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:qid, :name])
    |> validate_required([:qid, :name])
    |> unique_constraint(:qid)
  end

  @spec create_changeset(Ecto.Schema.t(), BotUser.t()) :: Ecto.Changeset.t()
  def create_changeset(user, %BotUser{} = user_params) do
    changeset(user, %{qid: user_params.qid, name: user_params.nickname})
  end
end
