defmodule DianBot.Schemas.Group do
  use TypedStruct

  typedstruct do
    field :gid, String.t(), enforce: true
    field :name, String.t(), enforce: true
    field :description, String.t()
  end
end
