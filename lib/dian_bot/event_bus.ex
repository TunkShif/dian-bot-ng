defmodule DianBot.EventBus do
  @moduledoc false

  @pubsub Dian.PubSub
  @topic "bot:event"

  def subscribe do
    Phoenix.PubSub.subscribe(@pubsub, @topic)
  end

  def broadcast(event) do
    Phoenix.PubSub.broadcast!(@pubsub, @topic, event)
  end
end
