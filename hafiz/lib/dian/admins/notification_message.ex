defmodule Dian.Admins.NotificationMessage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notification_messages" do
    field :template, :string
    field :operator_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(notification_message, attrs) do
    notification_message
    |> cast(attrs, [:template])
    |> validate_required([:template])
  end
end
