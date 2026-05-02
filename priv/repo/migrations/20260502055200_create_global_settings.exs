defmodule Dian.Repo.Migrations.CreateGlobalSettings do
  use Ecto.Migration

  def change do
    create table(:global_settings) do
      add :superadmin_user_id, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
