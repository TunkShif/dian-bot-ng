defmodule Dian.Accounts do
  import Ecto.Query

  alias Dian.Repo
  alias Dian.Chats.{User}
  alias Dian.Accounts.{UserToken, UserNotifier}

  @register_request_interval_in_mins 2

  @doc """
  Deliver registration instructions to the provided email.
  """
  def deliver_registration_email(email) do
    with {:ok, qid} <- validate_email(email),
         {:ok, %User{}} <- validate_non_registered(qid),
         :ok <- validate_request_interval(email),
         {encoded_token, user_token} = UserToken.build_email_token(email, :confirm),
         {:ok, _user_token} <- Repo.insert(user_token),
         {:ok, _email} <-
           UserNotifier.deliver_registration_instructions(
             email,
             build_verification_url(encoded_token)
           ) do
      :ok
    end
  end

  @spec validate_email(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  defp validate_email(email) when is_binary(email) do
    case Regex.named_captures(~r/^(?<qid>\d+)@qq\.com$/, email) do
      %{"qid" => qid} -> {:ok, qid}
      _ -> {:error, "invalid email"}
    end
  end

  # Check if the provided user could be registered or if the user has already registered
  @spec validate_non_registered(String.t()) :: {:ok, Ecto.Schema.t()} | {:error, String.t()}
  defp validate_non_registered(qid) do
    case Repo.get_by(User, qid: qid) do
      nil -> {:error, "invalid account"}
      %User{hashed_password: nil} = user -> {:ok, user}
      _ -> {:error, "already registered"}
    end
  end

  # Check if a user request a registration multiple times within 2 minutes
  @spec validate_request_interval(String.t()) :: :ok | {:error, String.t()}
  defp validate_request_interval(email) do
    query =
      from token in UserToken,
        where:
          token.sent_to == ^email and
            token.inserted_at > ago(@register_request_interval_in_mins, "minute"),
        select: token

    case Repo.one(query) do
      nil -> :ok
      %UserToken{} -> {:error, "already requested"}
    end
  end

  @spec build_verification_url(String.t()) :: String.t()
  defp build_verification_url(token) do
    app_url = Application.get_env(:dian, :app_url)
    "#{app_url}/verify/#{token}"
  end

  @doc """
  Verify the given `token` and return the `UserToken`.
  """
  @spec verify_email_user_token(String.t()) :: {:ok, Ecto.Schema.t()} | {:error, String.t()}
  def verify_email_user_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, :confirm),
         %UserToken{} = user_token <- Repo.one(query) do
      {:ok, user_token}
    else
      _ -> {:error, "invalid token"}
    end
  end

  @doc """
  Register a new user with the given `token`.
  """
  def register_user(token, attrs \\ %{}) do
    with {:ok, %UserToken{} = user_token} <- verify_email_user_token(token),
         {:ok, qid} <- validate_email(user_token.sent_to),
         {:ok, %User{} = user} <- validate_non_registered(qid) do
      Repo.update(User.register_changeset(user, attrs))
    end
  end

  @doc """
  Authenticate a user with qid and password, return a token if succeed otherwise nil.
  """
  @spec login_user(map()) :: String.t() | nil
  def login_user(params \\ %{}) do
    qid = params["qid"]
    password = params["password"]
    user = Repo.get_by(User, qid: qid)

    if User.valid_password?(user, password) do
      {token, user_token} = UserToken.build_session_token(user, params)
      Repo.insert!(user_token)
      token
    end
  end

  def get_user_by_session_token(token) do
    with {:ok, query} <- UserToken.verify_session_token_query(token) do
      Repo.one(query)
    else
      _ -> nil
    end
  end

  def delete_user_session_token(token) do
    # TODO: handle hashed token
    Repo.delete_all(UserToken.token_and_context_query())
  end
end
