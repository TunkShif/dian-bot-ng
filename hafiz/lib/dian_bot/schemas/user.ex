defmodule DianBot.Schemas.User do
  use TypedStruct

  typedstruct do
    field :qid, String.t(), enforce: true
    field :nickname, String.t(), enforce: true
  end
end
