defmodule Dian.Admins.PinnedMessage do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dian.Chats.User

  schema "pinned_messages" do
    field :type, Ecto.Enum, values: [:info, :alert, :news], default: :info
    field :title, :string
    field :content, :string

    belongs_to :operator, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(pinned_message, attrs) do
    pinned_message
    |> cast(attrs, [:type, :title, :content, :operator_id])
    |> validate_required([:type, :title, :content, :operator_id])
    |> validate_length(:title, max: 20)
    |> validate_length(:content, max: 100)
  end
end
