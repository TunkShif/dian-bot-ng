defmodule DianWeb.RoomChannel do
  use Phoenix.Channel

  alias DianWeb.Presence

  def join("room", _payload, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    user_id = socket.assigns.user_id

    metas = %{
      online_at: inspect(System.system_time(:second))
    }

    {:ok, _} = Presence.track(socket, user_id, metas)
    push(socket, "presence_state", Presence.list(socket))

    {:noreply, socket}
  end
end
