defmodule Dian.Repo.Migrations.CreateUserTokens do
  use Ecto.Migration

  def change do
    create table(:user_tokens) do
      add :token, :binary, null: false
      add :context, :string
      add :device, :string
      add :location, :string
      add :sent_to, :string

      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:user_tokens, [:user_id])
  end
end
