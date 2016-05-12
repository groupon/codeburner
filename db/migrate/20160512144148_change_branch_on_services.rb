class ChangeBranchOnServices < ActiveRecord::Migration
  def change
    remove_column :burns, :branch
    add_column :burns, :branch_id, :integer, references: :branches

    Service.all.each do |service|
      branch = Branch.create(:service => service, :ref => 'master')
      service.burns.update_all(:branch_id => branch.id)
    end
  end
end
