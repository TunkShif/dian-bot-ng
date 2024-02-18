defmodule Dian.Repo.Migrations.AddUserPassword do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :hashed_password, :string
      add :role, :string, default: "user"
    end
  end
end
