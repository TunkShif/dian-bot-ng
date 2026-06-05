defmodule DianBot.Client.WebSocket.Supervisor do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    config = Application.fetch_env!(:dian, DianBot.Bot)

    children = [
      {DianBot.Client.WebSocket, [timeout: Keyword.get(config, :timeout, 5_000)]},
      {DianBot.Client.WebSocket.Transport,
       [
         endpoint: Keyword.fetch!(config, :endpoint),
         access_token: Keyword.fetch!(config, :access_token)
       ]}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
