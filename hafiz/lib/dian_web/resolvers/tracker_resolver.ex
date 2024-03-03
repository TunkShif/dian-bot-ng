defmodule DianWeb.TrackerResolver do
  alias Dian.Repo
  alias Dian.Tracker

  def list_user_activities(args, _info) do
    Tracker.list_user_activities_query()
    |> Absinthe.Relay.Connection.from_query(&Repo.all/1, args)
  end
end
