defmodule Dian.Accounts.Passkey do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users_passkeys" do
    field :label, :string
    field :credential_id, :binary
    field :user_handle, :binary
    field :public_key, :binary
    field :sign_count, :integer, default: 0
    field :last_used_at, :utc_datetime
    belongs_to :user, Dian.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def registration_changeset(passkey, attrs, user_scope) do
    passkey
    |> cast(attrs, [:label, :credential_id, :user_handle, :public_key, :sign_count, :last_used_at])
    |> validate_required([:label, :credential_id, :user_handle, :public_key])
    |> validate_sign_count()
    |> validate_label()
    |> put_change(:user_id, user_scope.user.id)
    |> unique_constraint(:credential_id)
  end

  def label_changeset(passkey, attrs) do
    passkey
    |> cast(attrs, [:label])
    |> validate_required([:label])
    |> validate_label()
  end

  def usage_changeset(passkey, attrs) do
    passkey
    |> cast(attrs, [:last_used_at, :sign_count])
    |> validate_required([:last_used_at, :sign_count])
    |> validate_sign_count()
  end

  defp validate_label(changeset) do
    validate_length(changeset, :label, min: 1, max: 80)
  end

  defp validate_sign_count(changeset) do
    validate_number(changeset, :sign_count, greater_than_or_equal_to: 0)
  end
end
