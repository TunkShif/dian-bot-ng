defmodule Dian.Repo do
  use Ecto.Repo,
    otp_app: :dian,
    adapter: Ecto.Adapters.Postgres
end
