class AddHtmlUrlToServices < ActiveRecord::Migration
  def change
    add_column :repos, :html_url, :string
  end
end
