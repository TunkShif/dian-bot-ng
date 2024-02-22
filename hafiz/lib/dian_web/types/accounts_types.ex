defmodule DianWeb.AccountsTypes do
  use Absinthe.Schema.Notation

  object :user do
    field :id, non_null(:id)
    field :qid, non_null(:string)
    field :name, non_null(:string)
  end
end
