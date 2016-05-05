class AddLanguagesToServices < ActiveRecord::Migration
  def change
    add_column :services, :languages, :string
  end
end
