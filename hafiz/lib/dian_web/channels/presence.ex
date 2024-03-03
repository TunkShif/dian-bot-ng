defmodule DianWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :dian,
    pubsub_server: Dian.PubSub

  alias Dian.Accounts

  def fetch(_topic, presences) do
    users = presences |> Map.keys() |> Accounts.get_user_maps()

    for {key, %{metas: metas}} <- presences, into: %{} do
      user = users[String.to_integer(key)]
      global_id = Absinthe.Relay.Node.to_global_id(:user, key, DianWeb.Schema)

      {global_id, %{metas: metas, user: %{qid: user.qid, name: user.name}}}
    end
  end
end
