class FixServiceNames < ActiveRecord::Migration
  def change
    Repo.has_burns.all.each do |repo|
      burn = Burn.repo_id(repo.id).status('done').last

      if burn
        name = URI.parse(burn.repo_url).path[1..-1]
        repo.update(:name => name, :full_name => name)
      else
        # Burn.repo_id(repo.id).destroy_all
        # ServiceStat.destroy(Repo.find(repo.id).repo_stat.id)
        # Repo.destroy(repo.id)
      end
    end
  end
end
