defmodule Svradmin.Repo.Migrations.AlterIssue do
  use Ecto.Migration

  def change do
    execute """
    ALTER TABLE `issues`
    ADD `designer_infos` varchar(255) NULL AFTER `is_done_design`,
    CHANGE `frontend_id` `frontend_ids` varchar(255) NULL AFTER `designer_infos`,
    CHANGE `backend_id` `backend_ids` varchar(255) NULL AFTER `frontend_ids`,
    COMMENT='';
    ALTER TABLE `issues`
    CHANGE `designer_infos` `designer_infos` varchar(255) COLLATE 'utf8_general_ci' NULL DEFAULT '[]' AFTER `is_done_design`,
    COMMENT='';
    """
  end
end
