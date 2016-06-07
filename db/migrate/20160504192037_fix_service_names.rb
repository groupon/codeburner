class FixServiceNames < ActiveRecord::Migration
  def change
    Repo.all.each do |repo|
      burn = Burn.where(:repo_id => repo.id).last

      if burn and burn[:repo_url]
        new_name = URI.parse(burn.repo_url).path[1..-1]
        repo.name = new_name
        repo.full_name = new_name
        repo.save
      else
        Burn.where(:repo_id => repo.id).destroy_all
        stat = ServiceStat.where(:repo_id => repo.id).first
        ServiceStat.destroy(stat.id) if stat
        Repo.destroy(repo.id) if repo
      end
    end
  end
end
