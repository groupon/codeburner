class AddFirstAppearedAndLatestToFindings < ActiveRecord::Migration
  def change
    add_column :findings, :first_appeared, :string
    add_column :findings, :state, :string

    Finding.update_all(:current => true)

    Finding.all.each do |finding|
      finding.update(:first_appeared => finding.burn.revision)
    end
  end
end
