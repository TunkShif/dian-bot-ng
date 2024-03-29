defmodule Dian.Accounts.UserToken do
  use Ecto.Schema
  import Ecto.Query

  alias Dian.Chats.User
  alias Dian.Accounts.UserToken

  @rand_size 32
  @hash_algorithm :sha256
  @confirm_validity_in_mins 20
  @session_validity_in_days 20

  @contexts ~w(session confirm feeds)a

  schema "user_tokens" do
    field :token, :binary
    field :context, Ecto.Enum, values: @contexts
    field :device, :string
    field :location, :string
    field :sent_to, :string

    belongs_to :user, User

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc """
  Returns encoded token and hashed token.
  """
  def build_hashed_token() do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)
    {Base.encode64(token, padding: false), hashed_token}
  end

  @doc """
  Returns the token struct for the given token value and context.
  """
  def token_and_context_query(encoded_token, context) do
    case Base.decode64(encoded_token, padding: false) do
      {:ok, token} ->
        hashed_token = :crypto.hash(@hash_algorithm, token)
        query = from UserToken, where: [token: ^hashed_token, context: ^context]
        {:ok, query}

      :error ->
        :error
    end
  end

  @doc """
  Generates a token that will be stored in a signed place,
  such as session or cookie. As they are signed, those
  tokens do not need to be hashed.

  The reason why we store session tokens in the database, even
  though Phoenix already provides a session cookie, is because
  Phoenix' default session cookies are not persisted, they are
  simply signed and potentially encrypted. This means they are
  valid indefinitely, unless you change the signing/encryption
  salt.

  Therefore, storing them allows individual user
  sessions to be expired. The token system can also be extended
  to store additional data, such as the device used for logging in.
  You could then use this information to display all valid sessions
  and devices in the UI and allow users to explicitly expire any
  session they deem invalid.
  """
  def build_session_token(user, params \\ %{}) do
    {encoded_token, hashed_token} = build_hashed_token()

    {encoded_token,
     %UserToken{
       token: hashed_token,
       context: :session,
       user_id: user.id,
       device: params["device"],
       location: params["location"]
     }}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  The token is valid if it matches the value in the database and it has
  not expired (after @session_validity_in_days).
  """
  def verify_session_token_query(token) do
    with {:ok, query} <- token_and_context_query(token, :session) do
      query =
        from token in query,
          join: user in assoc(token, :user),
          where: token.inserted_at > ago(@session_validity_in_days, "day"),
          select: user

      {:ok, query}
    end
  end

  @doc """
  Builds a token and its hash to be delivered to the user's email.

  The non-hashed token is sent to the user email while the
  hashed part is stored in the database. The original token cannot be reconstructed,
  which means anyone with read-only access to the database cannot directly use
  the token in the application to gain access. Furthermore, if the user changes
  their email in the system, the tokens sent to the previous email are no longer
  valid.

  Users can easily adapt the existing code to provide other types of delivery methods,
  for example, by phone numbers.
  """
  def build_email_token(email, context) do
    {encoded_token, hashed_token} = build_hashed_token()

    {encoded_token,
     %UserToken{
       token: hashed_token,
       context: context,
       sent_to: email
     }}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user token.

  The given token is valid if it matches its hashed counterpart in the
  database and the user email has not changed. This function also checks
  if the token is being used within a certain period, depending on the
  context. The default contexts supported by this function are either
  "confirm", for account confirmation emails, and "reset_password",
  for resetting the password. For verifying requests to change the email,
  see `verify_change_email_token_query/2`.
  """
  def verify_email_token_query(token, context) do
    with {:ok, query} <- token_and_context_query(token, context) do
      query =
        from token in query,
          where:
            token.inserted_at > ago(@confirm_validity_in_mins, "minute") and
              not is_nil(token.sent_to),
          select: token

      {:ok, query}
    end
  end
end
