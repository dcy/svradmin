defmodule Svradmin.Repo.Migrations.CreateIssue do
  use Ecto.Migration

  def change do
    create table(:issues) do
      add :version_id, :integer
      add :title, :string
      add :content, :string
      add :designer_id, :integer
      add :is_done_design, :integer
      add :frontend_id, :integer
      add :backend_id, :integer
      add :remark, :string

      timestamps
    end

  end
end
