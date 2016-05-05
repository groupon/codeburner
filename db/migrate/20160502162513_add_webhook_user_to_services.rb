class AddWebhookUserToServices < ActiveRecord::Migration
  def change
    add_reference :services, :webhook_user, references: :users, index: true
    add_foreign_key :services, :users, column: :webhook_user_id
  end
end
