class AddBranchToFindings < ActiveRecord::Migration
  def change
    add_reference :findings, :branch, index: true, foreign_key: true

    Finding.all.each do |finding|
      finding.update(:branch => finding.repo.branches.first)
    end
  end
end
