class RenameColumnsForServiceToRepoChange < ActiveRecord::Migration
  def change
    rename_column :branches, :service_id, :repo_id
    rename_column :burns, :service_id, :repo_id
    rename_column :filters, :service_id, :repo_id
    rename_column :findings, :service_id, :repo_id
    rename_column :repos, :name, :name
    rename_column :repos, :full_name, :full_name
  end
end
