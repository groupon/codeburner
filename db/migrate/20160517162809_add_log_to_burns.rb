class AddLogToBurns < ActiveRecord::Migration
  def change
    add_column :burns, :log, :text
  end
end
