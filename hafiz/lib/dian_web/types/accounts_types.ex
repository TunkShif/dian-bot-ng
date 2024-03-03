defmodule DianWeb.AccountsTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias DianWeb.AccountsResolver

  object :me_queries do
    field :me, :user, resolve: &AccountsResolver.current_user/3
  end

  node object(:user) do
    field :qid, non_null(:string)
    field :name, non_null(:string)
    field :role, non_null(:user_role)
    field :statistics, non_null(:user_statistics), resolve: &AccountsResolver.user_statistics/3

    field :notification_message, :notification_message,
      resolve: &AccountsResolver.user_notification_message/3

    # TODO: complete connections later
    connection field :threads, node_type: :thread do
      resolve &AccountsResolver.user_threads/2
    end
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
