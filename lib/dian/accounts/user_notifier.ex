defmodule Dian.Accounts.UserNotifier do
  import Swoosh.Email

  alias Dian.Mailer
  alias Dian.Accounts.User

  @default_sender "contact@example.com"
  @sender_pattern ~r/^\s*(?:(?<name>[^<]+?)\s*<)?(?<email>[^<>@\s]+@[^<>@\s]+)(?:>)?\s*$/

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    sender = sender()

    email =
      new()
      |> to(recipient)
      |> from(sender)
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  defp sender do
    Application.get_env(:dian, __MODULE__, [])
    |> Keyword.get(:sender, @default_sender)
    |> normalize_sender()
  end

  defp normalize_sender(sender) when is_binary(sender) do
    sender = String.trim(sender)

    case Regex.named_captures(@sender_pattern, sender) do
      %{"name" => name, "email" => email} when name in [nil, ""] ->
        {"", email}

      %{"name" => name, "email" => email} ->
        {String.trim(name), email}

      _ ->
        {"", sender}
    end
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to log in with a magic link.
  """
  def deliver_login_instructions(user, url) do
    case user do
      %User{confirmed_at: nil} -> deliver_confirmation_instructions(user, url)
      _ -> deliver_magic_link_instructions(user, url)
    end
  end

  defp deliver_magic_link_instructions(user, url) do
    deliver(user.email, "Log in instructions", """

    ==============================

    Hi #{user.email},

    You can log into your account by visiting the URL below:

    #{url}

    If you didn't request this email, please ignore this.

    ==============================
    """)
  end

  defp deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirmation instructions", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end
end
