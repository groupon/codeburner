class AddHtmlUrlToServices < ActiveRecord::Migration
  def change
    add_column :services, :html_url, :string
  end
end
