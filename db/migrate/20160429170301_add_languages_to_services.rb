class AddLanguagesToServices < ActiveRecord::Migration
  def change
    add_column :repos, :languages, :string
  end
end
