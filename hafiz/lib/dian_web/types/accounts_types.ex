defmodule DianWeb.AccountsTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias DianWeb.AccountsResolver

  object :accounts_queries do
    field :me, :me, resolve: &AccountsResolver.me/3

    connection field :users, node_type: :user, non_null: true do
      resolve &AccountsResolver.list_users/2
    end
  end

  object :accounts_mutations do
    field :update_user_role, type: :user do
      arg :id, non_null(:id)
      arg :role, non_null(:user_role)

      resolve &AccountsResolver.update_user_role/3
    end

    field :cancel_user_account, type: :user do
      arg :id, non_null(:id)

      resolve &AccountsResolver.cancel_user_account/3
    end
  end

  object :me do
    @desc "Current logged-in user"
    field :user, :user, resolve: &AccountsResolver.current_user/3

    field :perms, non_null(list_of(non_null(:string))), resolve: &AccountsResolver.user_perms/3

    @desc "User token for socket usage"
    field :token, :string, resolve: &AccountsResolver.user_token/3

    @desc "User statistics including counts of messages, threads and followers"
    field :statistics, non_null(:user_statistics) do
      resolve &AccountsResolver.user_statistics/3
    end

    @desc "Notification message template for the current user"
    field :notification_message, :notification_message do
      resolve &AccountsResolver.user_notification_message/3
    end
  end

  connection(:user, node_type: non_null(:user), non_null: true)

  node object(:user) do
    field :qid, non_null(:string)
    field :name, non_null(:string)
    field :role, non_null(:user_role)
    field :registered, non_null(:boolean), resolve: &AccountsResolver.user_registered/3
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
