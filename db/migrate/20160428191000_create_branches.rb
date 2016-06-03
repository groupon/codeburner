class CreateBranches < ActiveRecord::Migration
  def change
    create_table :branches do |t|
      t.references :service, index: true, foreign_key: true
      t.string :name
      t.timestamps null: false
    end
  end
end
