class ChangeBranchOnServices < ActiveRecord::Migration
  def change
    remove_column :burns, :branch
    add_column :burns, :branch_id, :integer, references: :branches

    Repo.all.each do |repo|
      branch = Branch.create(:repo => repo, :name => 'master')
      repo.burns.update_all(:branch_id => branch.id)
    end
  end
end
