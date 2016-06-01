class RenameServicesToRepositories < ActiveRecord::Migration
  def change
    rename_table :repos, :repos
end
