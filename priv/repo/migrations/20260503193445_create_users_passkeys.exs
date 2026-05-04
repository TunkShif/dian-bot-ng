defmodule Dian.Repo.Migrations.CreateUsersPasskeys do
  use Ecto.Migration

  def change do
    create table(:users_passkeys) do
      add :label, :string, null: false
      add :credential_id, :binary, null: false
      add :user_handle, :binary, null: false
      add :public_key, :binary, null: false
      add :sign_count, :integer, null: false, default: 0
      add :last_used_at, :utc_datetime
      add :user_id, references(:users, type: :id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:users_passkeys, [:user_id])
    create index(:users_passkeys, [:user_handle])
    create unique_index(:users_passkeys, [:credential_id])
  end
end
