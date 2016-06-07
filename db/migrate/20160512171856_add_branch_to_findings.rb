class AddBranchToFindings < ActiveRecord::Migration
  def change
    add_reference :findings, :branch, index: true, foreign_key: true
  end
end
