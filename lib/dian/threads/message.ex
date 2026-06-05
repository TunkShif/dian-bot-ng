defmodule Dian.Threads.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    belongs_to :thread, Dian.Threads.Thread
    field :raw_message_id, :string
    field :sender_id, :string
    field :segments, {:array, :map}
    field :types, {:array, :string}
    field :text_content, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:thread_id, :raw_message_id, :sender_id, :segments, :types, :text_content])
    |> validate_required([:thread_id, :raw_message_id, :sender_id, :segments, :types])
    |> foreign_key_constraint(:thread_id)
  end
end
