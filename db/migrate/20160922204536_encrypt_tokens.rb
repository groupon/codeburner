class EncryptTokens < ActiveRecord::Migration
  def up
    rename_column :users, :access_token, :old_token
    add_column :users, :encrypted_access_token, :string
    add_column :users, :encrypted_access_token_iv, :string

    User.find_each do |u|
      u.access_token = u.old_token
      u.save
    end

    remove_column :users, :old_token
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
