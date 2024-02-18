defmodule Dian.Chats.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias DianBot.Schemas.User, as: BotUser
  alias Dian.Chats.{User, Thread, Message}
  alias Dian.Accounts.{UserToken}

  schema "users" do
    field :qid, :string
    field :name, :string

    field :hashed_password, :string
    field :password, :string, virtual: true, redact: true
    field :password_confirmation, :string, virtual: true, redact: true

    field :role, Ecto.Enum, values: [:user, :admin]

    has_many :tokens, UserToken

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

  def register_changeset(user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 10, max: 72)
    |> validate_confirmation(:password)
    |> put_hashed_password()
  end

  defp put_hashed_password(changeset) do
    password = get_change(changeset, :password)

    if password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  def is_admin?(%User{role: :admin}), do: true
  def is_admin?(_), do: false

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end
end
