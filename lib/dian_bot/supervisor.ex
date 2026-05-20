defmodule DianBot.Supervisor do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children =
      case DianBot.Client.impl() do
        DianBot.Client.WebSocket ->
          [
            DianBot.Client.WebSocket,
            DianBot.Commands.Throttle,
            DianBot.Commands.Consumer,
            DianBot.Commands.Batch
          ]

        _ ->
          []
      end

    Supervisor.init(children, strategy: :one_for_one)
  end
end
