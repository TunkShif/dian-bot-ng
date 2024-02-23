defmodule DianWeb.AccountsTypes do
  use Absinthe.Schema.Notation

  alias DianWeb.AccountsResolver

  object :me_queries do
    field :me, non_null(:me), resolve: fn _, _, _ -> {:ok, %{}} end
  end

  object :me do
    field :user, :user do
      resolve &AccountsResolver.fetch_current_user/3
    end
  end

  object :user do
    field :id, non_null(:id)
    field :qid, non_null(:string)
    field :role, non_null(:user_role)
    field :name, non_null(:string)
  end

  enum :user_role do
    value :user
    value :admin
  end
end
