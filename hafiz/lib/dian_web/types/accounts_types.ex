defmodule DianWeb.AccountsTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias DianWeb.AccountsResolver

  object :me_queries do
    field :me, :me, resolve: &AccountsResolver.me/3
  end

  object :me do
    @desc "Current logged-in user"
    field :user, :user, resolve: &AccountsResolver.current_user/3

    @desc "User token for socket usage"
    field :token, :string, resolve: &AccountsResolver.user_token/3

    field :statistics, non_null(:user_statistics) do
      resolve &AccountsResolver.user_statistics/3
    end

    field :notification_message, :notification_message do
      resolve &AccountsResolver.user_notification_message/3
    end
  end

  node object(:user) do
    field :qid, non_null(:string)
    field :name, non_null(:string)
    field :role, non_null(:user_role)
  end

  enum :user_role do
    value :user
    value :admin
  end

  object :user_statistics do
    field :chats, non_null(:integer)
    field :threads, non_null(:integer)
    field :followers, non_null(:integer)
  end
end
