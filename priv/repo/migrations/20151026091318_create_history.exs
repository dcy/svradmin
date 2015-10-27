defmodule Svradmin.Repo.Migrations.CreateHistory do
  use Ecto.Migration

  def change do
    create table(:historys) do
      add :who, :string
      add :what, :integer
      add :svr_id, :integer

      timestamps
    end

  end
end
