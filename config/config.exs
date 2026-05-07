# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :bun,
  version: "1.3.12",
  assets: [args: [], cd: Path.expand("../assets", __DIR__)],
  typegen: [args: ~w(run typegen), cd: Path.expand("../assets", __DIR__)],
  precommit: [args: ~w(run precommit), cd: Path.expand("../assets", __DIR__)],
  vite: [
    args: ~w(x vite),
    cd: Path.expand("../assets", __DIR__),
    env: %{"MIX_BUILD_PATH" => Mix.Project.build_path()}
  ]

config :dian, :scopes,
  user: [
    default: true,
    module: Dian.Accounts.Scope,
    assign_key: :current_scope,
    access_path: [:user, :id],
    schema_key: :user_id,
    schema_type: :id,
    schema_table: :users,
    test_data_fixture: Dian.AccountsFixtures,
    test_setup_helper: :register_and_log_in_user
  ]

config :dian,
  ecto_repos: [Dian.Repo],
  generators: [timestamp_type: :utc_datetime]

config :dian, Dian.Media,
  bundled_fonts_dir: "priv/fonts",
  default_timeout: 5_000,
  load_system_fonts: true,
  max_font_count: 8,
  max_pixels: 16_000_000,
  max_scale: 4.0,
  max_svg_bytes: 250_000

config :dian, :notification_locale, :zh

# Configure the endpoint
config :dian, DianWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: DianWeb.ErrorHTML, json: DianWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Dian.PubSub,
  live_view: [signing_salt: "gZOMAyPj"]

# Configure the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :dian, Dian.Mailer, adapter: Swoosh.Adapters.Local

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
