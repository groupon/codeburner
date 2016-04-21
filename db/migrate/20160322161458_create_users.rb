class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :github_uid
      t.string :name
      t.string :profile_url
      t.string :avatar_url
      t.string :access_token

      t.timestamps null: false
    end
  end
end
