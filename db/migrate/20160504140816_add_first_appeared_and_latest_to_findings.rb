class AddFirstAppearedAndLatestToFindings < ActiveRecord::Migration
  def change
    add_column :findings, :first_appeared, :string
    add_column :findings, :current, :boolean

    Finding.update_all(:current => true)
  end
end
