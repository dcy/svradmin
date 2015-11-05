defmodule Svradmin.Repo.Migrations.CreateVersion do
  use Ecto.Migration

  def change do
    create table(:versions) do
      add :name, :string
      add :start, :datetime
      add :end, :datetime

      timestamps
    end

  end
end
