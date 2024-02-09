# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :dian,
  ecto_repos: [Dian.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :dian, DianWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: DianWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Dian.PubSub,
  live_view: [signing_salt: "f8MzOaNB"]

# Configure tesla client adapter
config :tesla, :adapter, {Tesla.Adapter.Finch, name: Dian.Finch}

# Configures default bot adapter
config :dian, DianBot, adapter: DianBot.Adapters.OnebotAdapter

# Configures default storgae provider
config :dian, Dian.Storage, adapter: Dian.Storage.Adapters.SupabaseAdapter

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :dian, Dian.Mailer, adapter: Swoosh.Adapters.Local

# Configure oban jobs
config :dian, Oban,
  repo: Dian.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 4]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
