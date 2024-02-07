import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :dian, Dian.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "dian_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :dian, DianWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "JdmXVkzApsDJilOxyShQ8BKrHMw9WRytKbry3hu5/e5L1/tYd+Afh5TraZkoSX3W",
  server: false

# In test we don't send emails.
config :dian, Dian.Mailer, adapter: Swoosh.Adapters.Test

# Use local mock server for onebot adapter
config :dian, DianBot,
  secret: "1234",
  base_url: "http://localhost:4320/bot",
  access_token: "secret token"

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Prevent Oban from running jobs and plugins during test runs
config :dian, Oban, testing: :inline

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
