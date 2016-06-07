class AddWebhookUserToServices < ActiveRecord::Migration
  def change
    add_reference :repos, :webhook_user, references: :users, index: true
    add_foreign_key :repos, :users, column: :webhook_user_id
  end
end
