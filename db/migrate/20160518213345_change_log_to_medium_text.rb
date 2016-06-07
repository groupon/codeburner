class ChangeLogToMediumText < ActiveRecord::Migration
  def change
    change_column :burns, :log, :text, limit: 16.megabytes - 1
  end
end
