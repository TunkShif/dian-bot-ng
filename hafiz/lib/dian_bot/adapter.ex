defmodule DianBot.Adapter do
  alias DianBot.BotError
  alias DianBot.Schemas.{User, Group, Message, Event}

  @type result(t) :: {:ok, t} | error()

  @type error :: {:error, BotError.t()}

  @callback is_online() :: boolean()

  @callback get_message(String.t()) :: result(Message.t())
  @callback get_forwarded_messages(String.t()) :: result([Message.t()])

  @callback get_user(String.t()) :: result(User.t())
  @callback get_group(String.t()) :: result(Group.t())

  @callback send_group_message(String.t(), String.t()) :: :ok | error()

  @callback set_honorable_message(String.t()) :: :ok | error()

  @callback parse_event(map(), keyword()) :: result(Event.t())
end
