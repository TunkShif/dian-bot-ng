dev-server:
  cd hafiz && mix phx.server

dev-mock:
  cd mock && bun dev

dev-app:
  cd kitab && pnpm dev

repl-server:
  cd hafiz && iex -S mix phx.server

format-server:
  cd hafiz && mix format

format-app:
  cd kitab && pnpm format

format-all: format-app format-server
