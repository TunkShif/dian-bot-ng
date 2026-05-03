defmodule Dian.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Dian.Accounts.{Passkey, Scope, User, UserNotifier, UserToken}
  alias Dian.Repo
  alias Dian.Settings

  @user_details_cache_key_prefix "accounts:user_details:"
  @user_details_cache_ttl :timer.hours(24)

  def extract_qq_id_from(email) when is_binary(email) do
    String.trim_trailing(email, "@qq.com")
  end

  def build_user_avatar_url(qq_id, size \\ 640),
    do: "https://q1.qlogo.cn/g?b=qq&nk=#{qq_id}&s=#{size}"

  def get_user_details(%User{} = user) do
    cache_key = user_details_cache_key(user)

    case Cachex.get(:dian_cache, cache_key) do
      {:ok, nil} ->
        fetch_and_maybe_cache_user_details(user, cache_key)

      {:ok, details} ->
        details

      {:error, _reason} ->
        fetch_and_maybe_cache_user_details(user, cache_key)
    end
  end

  defp user_details_cache_key(%User{} = user),
    do: @user_details_cache_key_prefix <> to_string(user.id)

  defp fetch_and_maybe_cache_user_details(%User{} = user, cache_key) do
    qq_id = extract_qq_id_from(user.email)
    member = DianBot.find_group_member_in_any_group(qq_id)

    details = build_user_details(member, user, qq_id)

    if member do
      Cachex.put(:dian_cache, cache_key, details, expire: @user_details_cache_ttl)
    else
      # TODO: Broadcast a PubSub event when an existing user can no longer be
      # found in any bot group, so a worker can mark the user inactive or locked.
    end

    details
  end

  defp build_user_details(member, %User{} = user, qq_id) do
    %{
      id: user.id,
      qq_id: qq_id,
      nickname: member_nickname(member, qq_id),
      avatar_url: build_user_avatar_url(qq_id)
    }
  end

  defp member_nickname(nil, qq_id), do: qq_id
  defp member_nickname(%{nickname: nickname}, qq_id) when nickname in [nil, ""], do: qq_id
  defp member_nickname(%{nickname: nickname}, _qq_id), do: nickname

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :user,
      %User{}
      |> User.email_changeset(attrs)
      |> validate_registration()
    )
    |> Ecto.Multi.run(
      :settings,
      fn repo, %{user: user} -> Settings.maybe_set_superadmin(repo, user.id) end
    )
    |> Repo.transact()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, _step, %Ecto.Changeset{} = changeset, _changes} -> {:error, changeset}
      {:error, _step, reason, _changes} -> {:error, reason}
    end
  end

  defp validate_registration(changeset) do
    changeset
    |> Ecto.Changeset.validate_change(:email, fn :email, email ->
      qq_id = extract_qq_id_from(email)

      if Settings.can_user_register?(qq_id) do
        []
      else
        [email: "not permitted to register"]
      end
    end)
  end

  def begin_passkey_registration(%Scope{user: %User{} = user}) do
    challenge = Wax.new_registration_challenge()
    user_handle = passkey_user_handle(user)

    options = %{
      challenge: Base.url_encode64(challenge.bytes, padding: false),
      rp: %{id: challenge.rp_id, name: Application.spec(:dian, :description) |> to_string},
      user: %{
        id: Base.url_encode64(user_handle, padding: false),
        name: user.email,
        displayName: extract_qq_id_from(user.email)
      },
      pubKeyCredParams: [%{type: "public-key", alg: -7}],
      timeout: 60_000,
      authenticatorSelection: %{
        residentKey: "required",
        requireResidentKey: true,
        userVerification: "preferred"
      }
    }

    {challenge, options}
  end

  def complete_passkey_registration(%Scope{user: %User{} = user}, challenge, params) do
    with {:ok, attestation_object} <- fetch_base64url(params, ["response", "attestationObject"]),
         {:ok, client_data_json} <- fetch_base64url(params, ["response", "clientDataJSON"]),
         {:ok, {auth_data, _attestation_result}} <-
           Wax.register(attestation_object, client_data_json, challenge),
         %{credential_id: credential_id, credential_public_key: public_key} <-
           auth_data.attested_credential_data do
      label = passkey_label(params)

      %Passkey{}
      |> Passkey.registration_changeset(
        %{
          label: label,
          credential_id: credential_id,
          user_handle: passkey_user_handle(user),
          public_key: :erlang.term_to_binary(public_key),
          sign_count: auth_data.sign_count
        },
        Scope.for_user(user)
      )
      |> Repo.insert()
    else
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      _ -> {:error, :invalid_webauthn_response}
    end
  end

  def list_user_passkeys(%Scope{user: %User{id: user_id}}) do
    Passkey
    |> where([p], p.user_id == ^user_id)
    |> order_by([p], desc: p.last_used_at, desc: p.inserted_at)
    |> Repo.all()
  end

  def update_user_passkey(%Scope{user: %User{id: user_id}}, passkey_id, attrs) do
    with %Passkey{} = passkey <- Repo.get_by(Passkey, id: passkey_id, user_id: user_id) do
      passkey
      |> Passkey.label_changeset(attrs)
      |> Repo.update()
    else
      nil -> {:error, :not_found}
    end
  end

  def delete_user_passkey(%Scope{user: %User{id: user_id}}, passkey_id) do
    with %Passkey{} = passkey <- Repo.get_by(Passkey, id: passkey_id, user_id: user_id),
         {:ok, _passkey} <- Repo.delete(passkey) do
      :ok
    else
      nil -> {:error, :not_found}
      {:error, changeset} -> {:error, changeset}
    end
  end

  ## Settings

  @doc """
  Checks whether the user is in sudo mode.

  The user is in sudo mode when the last authentication was done no further
  than 20 minutes ago. The limit can be given as second argument in minutes.
  """
  def sudo_mode?(user, minutes \\ -20)

  def sudo_mode?(%User{authenticated_at: ts}, minutes) when is_struct(ts, DateTime) do
    DateTime.after?(ts, DateTime.utc_now() |> DateTime.add(minutes, :minute))
  end

  def sudo_mode?(_user, _minutes), do: false

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  See `Dian.Accounts.User.email_changeset/3` for a list of supported options.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}, opts \\ []) do
    User.email_changeset(user, attrs, opts)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    Repo.transact(fn ->
      with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
           %UserToken{sent_to: email} <- Repo.one(query),
           {:ok, user} <- Repo.update(User.email_changeset(user, %{email: email})),
           {_count, _result} <-
             Repo.delete_all(from(UserToken, where: [user_id: ^user.id, context: ^context])) do
        {:ok, user}
      else
        _ -> {:error, :transaction_aborted}
      end
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  See `Dian.Accounts.User.password_changeset/3` for a list of supported options.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}, opts \\ []) do
    User.password_changeset(user, attrs, opts)
  end

  @doc """
  Updates the user password.

  Returns a tuple with the updated user, as well as a list of expired tokens.

  ## Examples

      iex> update_user_password(user, %{password: ...})
      {:ok, {%User{}, [...]}}

      iex> update_user_password(user, %{password: "too short"})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> update_user_and_delete_all_tokens()
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.

  If the token is valid `{user, token_inserted_at}` is returned, otherwise `nil` is returned.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Gets the user with the given magic link token.
  """
  def get_user_by_magic_link_token(token) do
    with {:ok, query} <- UserToken.verify_magic_link_token_query(token),
         {user, _token} <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Logs the user in by magic link.

  There are three cases to consider:

  1. The user has already confirmed their email. They are logged in
     and the magic link is expired.

  2. The user has not confirmed their email and no password is set.
     In this case, the user gets confirmed, logged in, and all tokens -
     including session ones - are expired. In theory, no other tokens
     exist but we delete all of them for best security practices.

  3. The user has not confirmed their email but a password is set.
     This cannot happen in the default implementation but may be the
     source of security pitfalls. See the "Mixing magic link and password registration" section of
     `mix help phx.gen.auth`.
  """
  def login_user_by_magic_link(token) do
    {:ok, query} = UserToken.verify_magic_link_token_query(token)

    case Repo.one(query) do
      # Prevent session fixation attacks by disallowing magic links for unconfirmed users with password
      {%User{confirmed_at: nil, hashed_password: hash}, _token} when not is_nil(hash) ->
        raise """
        magic link log in is not allowed for unconfirmed users with a password set!

        This cannot happen with the default implementation, which indicates that you
        might have adapted the code to a different use case. Please make sure to read the
        "Mixing magic link and password registration" section of `mix help phx.gen.auth`.
        """

      {%User{confirmed_at: nil} = user, _token} ->
        user
        |> User.confirm_changeset()
        |> update_user_and_delete_all_tokens()

      {user, token} ->
        Repo.delete!(token)
        {:ok, {user, []}}

      nil ->
        {:error, :not_found}
    end
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm-email/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Delivers the magic link login instructions to the given user.
  """
  def deliver_login_instructions(%User{} = user, magic_link_url_fun)
      when is_function(magic_link_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "login")
    Repo.insert!(user_token)
    UserNotifier.deliver_login_instructions(user, magic_link_url_fun.(encoded_token))
  end

  def begin_passkey_login() do
    challenge = Wax.new_authentication_challenge()

    options = %{
      challenge: Base.url_encode64(challenge.bytes, padding: false),
      rpId: challenge.rp_id,
      timeout: 60_000,
      userVerification: challenge.user_verification
    }

    {challenge, options}
  end

  def complete_passkey_login(challenge, params) do
    with {:ok, user_handle} <- fetch_base64url(params, ["response", "userHandle"]),
         passkeys when passkeys != [] <- list_passkeys_by_user_handle(user_handle),
         {:ok, credential_id} <- fetch_base64url(params, ["rawId"]),
         {:ok, authenticator_data} <- fetch_base64url(params, ["response", "authenticatorData"]),
         {:ok, client_data_json} <- fetch_base64url(params, ["response", "clientDataJSON"]),
         {:ok, signature} <- fetch_base64url(params, ["response", "signature"]),
         credentials = credentials_for_passkeys(passkeys),
         {:ok, auth_data} <-
           Wax.authenticate(
             credential_id,
             authenticator_data,
             signature,
             client_data_json,
             challenge,
             credentials
           ),
         %Passkey{} = passkey <- Enum.find(passkeys, &(&1.credential_id == credential_id)),
         {:ok, passkey} <- mark_passkey_used(passkey, auth_data),
         %User{} = user <- Repo.get(User, passkey.user_id) do
      {:ok, user}
    else
      [] -> {:error, :passkey_not_found}
      nil -> {:error, :passkey_not_found}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      _ -> {:error, :invalid_webauthn_response}
    end
  end

  defp passkey_user_handle(%User{id: user_id}), do: :crypto.hash(:sha256, "user-#{user_id}")

  defp passkey_label(%{"label" => label}) when is_binary(label) and label != "", do: label
  defp passkey_label(_params), do: "Passkey"

  defp list_passkeys_by_user_handle(user_handle) when is_binary(user_handle) do
    Passkey
    |> where([p], p.user_handle == ^user_handle)
    |> Repo.all()
  end

  defp credentials_for_passkeys(passkeys) do
    Enum.map(passkeys, fn passkey ->
      {passkey.credential_id, :erlang.binary_to_term(passkey.public_key)}
    end)
  end

  defp mark_passkey_used(passkey, auth_data) do
    passkey
    |> Passkey.usage_changeset(%{
      last_used_at: DateTime.utc_now(:second),
      sign_count: auth_data.sign_count
    })
    |> Repo.update()
    |> case do
      {:ok, passkey} -> {:ok, passkey}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp fetch_base64url(params, path) do
    with value when is_binary(value) <- get_in(params, path),
         {:ok, decoded} <- Base.url_decode64(value, padding: false) do
      {:ok, decoded}
    else
      _ -> {:error, :invalid_base64url}
    end
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(from(UserToken, where: [token: ^token, context: "session"]))
    :ok
  end

  ## Token helper

  defp update_user_and_delete_all_tokens(changeset) do
    Repo.transact(fn ->
      with {:ok, user} <- Repo.update(changeset) do
        tokens_to_expire = Repo.all_by(UserToken, user_id: user.id)

        Repo.delete_all(from(t in UserToken, where: t.id in ^Enum.map(tokens_to_expire, & &1.id)))

        {:ok, {user, tokens_to_expire}}
      end
    end)
  end
end
