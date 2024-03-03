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
    |> cast(attrs, [:template])
    |> validate_required([:template, :operator_id])
    |> validate_length(:template, max: 120)
    |> unique_constraint([:operator_id], message: "already has a notification message")
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
    escaped_template = template |> String.replace("[", "&#91;") |> String.replace("]", "&#93;")
    :bbmustache.render(escaped_template, assigns, key_type: :atom)
  end
end
