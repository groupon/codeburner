class AddBranchToFindings < ActiveRecord::Migration
  def change
    #add_reference :findings, :branch, index: true, foreign_key: true

    Finding.all.each do |finding|
      branch = finding.service.branches.first
      finding.update(:branch => branch)
    end
  end
end
