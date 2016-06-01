class AddHtmlUrlToRepos < ActiveRecord::Migration
  def change
    Repo.all.each do |repo|
      repo.update(:html_url => "https://github.groupondev.com/#{repo.name}")
    end
  end
end
