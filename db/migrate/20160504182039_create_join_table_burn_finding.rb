class CreateJoinTableBurnFinding < ActiveRecord::Migration
  def change
    create_join_table :burns, :findings do |t|
      t.index [:burn_id, :finding_id]
      t.index [:finding_id, :burn_id]
    end

    Finding.all.each do |finding|
      finding.burns << Burn.where(:repo_id => finding.repo_id, :status => 'done').order('created_at').last
    end

  end
end
