class User < ActiveRecord::Base
  has_many :tokens
  has_many :burns
  has_and_belongs_to_many :repos

  enum role: [:user, :admin]
  after_initialize :set_default_role, :if => :new_record?

  def set_default_role
    self.role ||= :user
  end

  def update_repos
    self.update(:repos => [])

    github = CodeburnerUtil.user_github(self)
    local_repos = Rails.cache.fetch('repos') { CodeburnerUtil.get_repos }

    matched_repo_ids = []

    github.repos.each do |github_repo|
      matches = local_repos.select {|r| r['full_name'] == github_repo.full_name}

      if matches.length > 0
        matches.each do |match|
          matched_repo_ids << match['id']
        end
      end
    end

    matched_repos = Repo.find(matched_repo_ids)

    self.update(:repos => matched_repos)

    return self.repos
  end
end
