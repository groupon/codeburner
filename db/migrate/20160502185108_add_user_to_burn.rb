class AddUserToBurn < ActiveRecord::Migration
  def change
    add_reference :burns, :user, index: true, foreign_key: true
  end
end
