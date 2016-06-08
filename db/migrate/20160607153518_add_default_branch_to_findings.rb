class AddDefaultBranchToFindings < ActiveRecord::Migration
  def change
    Finding.all.each do |finding|
      finding.update(:branch => finding.repo.branches.first) unless finding.branch
    end
  end
end
