defmodule Dian.Admins.NotificationMessage do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dian.Chats.User
  alias Dian.Admins.NotificationMessage

  schema "notification_messages" do
    field :template, :string

    belongs_to :operator, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(notification_message, attrs) do
    notification_message
    |> cast(attrs, [:template, :operator_id])
    |> validate_required([:template, :operator_id])
    |> validate_length(:template, max: 60)
  end

  def create_changeset(notification_message, attrs) do
    changeset(notification_message, attrs)
    |> validate_template()
    |> unique_constraint([:operator_id], message: "already has a notification message")
  end

  def update_changeset(notification_message, attrs) do
    notification_message
    |> cast(attrs, [:template])
    |> validate_required([:template, :operator_id])
    |> validate_length(:template, max: 60)
    |> validate_template()
  end

  defp validate_template(changeset) do
    validate_change(changeset, :template, fn :template, template ->
      try do
        :bbmustache.parse_binary(template)
        []
      rescue
        _ -> [template: "invalid syntax"]
      end
    end)
  end

  def render_message(%NotificationMessage{template: template}, assigns) do
    :bbmustache.render(template, assigns, key_type: :binary)
  end
end
