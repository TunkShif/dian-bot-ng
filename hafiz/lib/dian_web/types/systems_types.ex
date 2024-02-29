defmodule DianWeb.SystemsTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  node object(:pinned_message) do
    field :type, :pinned_message_type
    field :content, :string
    field :operator, :user
  end

  enum :pinned_message_type do
    value :info
    value :alert
    value :news
  end
end
