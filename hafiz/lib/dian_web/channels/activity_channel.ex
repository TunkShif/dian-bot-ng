defmodule DianWeb.ActivityChannel do
  use Phoenix.Channel

  alias Dian.Tracker

  def join("activity", _payload, socket) do
    {:ok, socket}
  end

  def terminate(reason, socket) do
    # after a user closed a session, we try to persist the latest
    # event data from the cache
    user_id = socket.assigns.user_id
    Tracker.persist_activity(user_id)

    # the return value of this callback is ignored
    reason
  end

  def handle_in("move", payload, socket) do
    user_id = socket.assigns.user_id
    global_id = Absinthe.Relay.Node.to_global_id(:user, inspect(user_id), DianWeb.Schema)

    # when user move event comes in, we first cache the event payload,
    # and then broadcast the event to all the users online
    Tracker.cache_activity(Map.put(payload, "id", user_id))
    broadcast!(socket, "new_move", Map.put(payload, "id", global_id))

    {:noreply, socket}
  end
end
