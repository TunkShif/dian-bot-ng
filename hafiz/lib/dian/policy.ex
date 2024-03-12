defmodule Dian.Policy do
  alias Dian.Chats.User
  alias Dian.Admins.{PinnedMessage, NotificationMessage}

  defmodule AuthorizationError do
    defexception [:message]
  end

  defimpl Canada.Can, for: User do
    def can?(%User{role: role}, action, %User{})
        when action in [:update] and role in [:admin],
        do: :ok

    def can?(%User{role: role}, action, %PinnedMessage{})
        when action in [:create, :delete] and role in [:admin],
        do: :ok

    def can?(%User{role: role}, action, %NotificationMessage{})
        when action in [:create] and role in [:user, :admin],
        do: :ok

    def can?(%User{role: role}, action, :broadcast_message)
        when action in [:create] and role in [:admin],
        do: :ok

    def can?(_user, _action, _subject),
      do: {:error, %AuthorizationError{message: "Unauthorized user action"}}
  end
end
