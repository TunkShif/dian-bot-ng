defmodule Dian.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Oban.Telemetry.attach_default_logger()

    children = [
      DianWeb.Telemetry,
      Dian.Repo,
      {DNSCluster, query: Application.get_env(:dian, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Dian.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Dian.Finch},
      {Cachex, name: Dian.Cache},
      {Oban, Application.fetch_env!(:dian, Oban)},
      # Start a worker by calling: Dian.Worker.start_link(arg)
      # {Dian.Worker, arg},
      # Start to serve requests, typically the last entry
      DianWeb.Endpoint
    ]

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

  @impl true
  def stop(_state) do
    Oban.Telemetry.detach_default_logger()
  end
end
