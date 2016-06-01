class RenameServicesUsersToRepositoriesUsers < ActiveRecord::Migration
  def change
    rename_table :repos_users, :repos_users
  end
end
