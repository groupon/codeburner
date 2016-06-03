class RemoveBurnFromFindings < ActiveRecord::Migration
  def change
    remove_reference :findings, :burn, index: true, foreign_key: true
  end
end
