defmodule Dian.Tracker do
  import Ecto.Query

  alias Dian.Repo
  alias Dian.Tracker.Activity

  @cache Dian.Cache

  defp key(id), do: "activity:#{id}"

  def cache_activity(event) do
    Cachex.put(@cache, key(event["id"]), event, ttl: :timer.minutes(2))
  end

  @doc """
  Persist the latest user event data from the cache
  """
  def persist_activity(user_id) do
    case Cachex.get(@cache, key(user_id)) do
      {:ok, event} when not is_nil(event) ->
        attrs = %{
          location: event["location"],
          mouse_x: event["mouseX"],
          mouse_y: event["mouseY"],
          offline_at: NaiveDateTime.utc_now()
        }

        %Activity{user_id: user_id}
        |> Activity.changeset(attrs)
        |> Repo.insert!(on_conflict: [set: Enum.to_list(attrs)], conflict_target: :user_id)

      _ ->
        nil
    end
  end

  def list_user_activities_query() do
    from activity in Activity, order_by: [desc: activity.offline_at]
  end
end
