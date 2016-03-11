class ChangeFindingFileType < ActiveRecord::Migration
  def change
    change_column :findings, :file, :text
  end
end
