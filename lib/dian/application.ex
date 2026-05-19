defmodule Dian.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Dian.Steam.Client.Telemetry.attach()
    DianBot.Client.WebSocket.Telemetry.attach()

    children =
      [
        DianWeb.Telemetry,
        Dian.Repo,
        {Ecto.Migrator,
         repos: Application.fetch_env!(:dian, :ecto_repos), skip: skip_migrations?()},
        {DNSCluster, query: Application.get_env(:dian, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: Dian.PubSub},
        {Cachex, [:dian_cache]},
        {Task.Supervisor, name: Dian.Media.RenderTaskSupervisor},
        Dian.SteamWatcher.Supervisor,
        Dian.AI.DailySteamSummaryScheduler,
        # Start a worker by calling: Dian.Worker.start_link(arg)
        # {Dian.Worker, arg},
        # Start to serve requests, typically the last entry
        DianWeb.Endpoint
      ] ++ maybe_bot_client()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Dian.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DianWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp maybe_bot_client() do
    case DianBot.Client.impl() do
      DianBot.Client.WebSocket ->
        [
          DianBot.Client.WebSocket,
          DianBot.Commands.Consumer,
          DianBot.Commands.Batch
        ]

      _ ->
        []
    end
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") == nil
  end
end
