set dotenv-required

repl:
  iex -S mix

[group('db')]
db-setup:
  mix ecto.setup
