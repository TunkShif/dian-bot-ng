defmodule DianWeb.UserSocket do
  use Phoenix.Socket

  channel "room", DianWeb.RoomChannel
  channel "activity", DianWeb.ActivityChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    case Phoenix.Token.verify(socket, "user socket", token) do
      {:ok, user_id} -> {:ok, assign(socket, :user_id, user_id)}
      {:error, _reason} -> :error
    end
  end

  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.user_id}"
end
