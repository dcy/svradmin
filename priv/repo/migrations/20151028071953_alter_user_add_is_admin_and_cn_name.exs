defmodule Svradmin.Repo.Migrations.AlterUserAddIsAdminAndCnName do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :cn_name, :string
      add :is_admin, :integer, default: 0
    end
  end
end
