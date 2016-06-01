class AddUserToServices < ActiveRecord::Migration
  def change
    create_table :repos_users, :id => false do |t|
      t.references :repo, :user
    end    
  end
end
