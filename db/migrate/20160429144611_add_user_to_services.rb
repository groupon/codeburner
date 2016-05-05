class AddUserToServices < ActiveRecord::Migration
  def change
    create_table :services_users, :id => false do |t|
      t.references :service, :user
    end    
  end
end
