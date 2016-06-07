class AddForkedToServices < ActiveRecord::Migration
  def change
    add_column :repos, :forked, :boolean

    Repo.all.update_all(:forked => false)
  end
end
