class RenameServicesToRepositories < ActiveRecord::Migration
  def change
    rename_table :services, :repos
  end
end
