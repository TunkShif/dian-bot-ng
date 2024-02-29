defmodule Dian.Admins.PinnedMessage do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dian.Chats.User

  schema "pinned_messages" do
    field :type, Ecto.Enum, values: [:info, :alert, :news]
    field :content, :string

    belongs_to :operator, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(pinned_message, attrs) do
    pinned_message
    |> cast(attrs, [:type, :content])
    |> validate_required([:type, :content])
  end
end
