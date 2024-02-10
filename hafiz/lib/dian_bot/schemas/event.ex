defmodule DianBot.Schemas.Event do
  use TypedStruct

  alias DianBot.Schemas.{User, Group, Message}

  typedstruct do
    field :id, String.t(), enforce: true
    field :message, Message.t(), enforce: true
    field :owner, User.t(), enforce: true
    field :group, Group.t(), enforce: true
    field :marked_at, DateTime.t(), enforce: true
  end
end
