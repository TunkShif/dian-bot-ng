defmodule DianWeb.TrackerTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  import Absinthe.Resolution.Helpers

  alias Dian.Chats
  alias DianWeb.TrackerResolver

  object :tracker_queries do
    connection field :user_activities, node_type: :user_activity, non_null: true do
      resolve &TrackerResolver.list_user_activities/2
    end
  end

  connection(:user_activity, node_type: non_null(:user_activity), non_null: true)

  node object(:user_activity) do
    field :location, non_null(:string)
    field :mouse_x, non_null(:float)
    field :mouse_y, non_null(:float)
    field :offline_at, non_null(:naive_datetime)
    field :user, non_null(:user), resolve: dataloader(Chats)
  end
end
