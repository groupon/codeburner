class RenameColumnsForServiceToRepoChange < ActiveRecord::Migration
  def change
    rename_column :branches, :service_id, :repo_id
    rename_column :burns, :service_id, :repo_id
    rename_column :filters, :service_id, :repo_id
    rename_column :findings, :service_id, :repo_id
    rename_column :repos, :short_name, :name
    rename_column :repos, :pretty_name, :full_name
    rename_column :repos_users, :service_id, :repo_id
    rename_column :system_stats, :services, :repos
    rename_column :service_stats, :service_id, :repo_id

    SystemStat.first.versions.each do | version |
      o = YAML.load(version.object)
      o['repos'] = o.delete 'services'
      version.update(:object => o.to_yaml)
    end
  end
end
