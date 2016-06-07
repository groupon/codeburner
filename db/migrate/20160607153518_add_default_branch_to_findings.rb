class AddDefaultBranchToFindings < ActiveRecord::Migration
  def change
    Finding.all.each do |finding|
      finding.update(:branch => finding.repo.branches.first)
    end
  end
end
