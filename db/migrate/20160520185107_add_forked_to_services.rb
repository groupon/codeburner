class AddForkedToServices < ActiveRecord::Migration
  def change
    add_column :services, :forked, :boolean

    Service.all.update_all(:forked => false)
  end
end
