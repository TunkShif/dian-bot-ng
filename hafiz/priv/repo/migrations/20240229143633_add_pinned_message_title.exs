defmodule Dian.Repo.Migrations.AddPinnedMessageTitle do
  use Ecto.Migration

  def change do
    alter table(:pinned_messages) do
      add :title, :text
    end
  end
end
