class Branch < ActiveRecord::Base
  validates :name, uniqueness: { scope: :repo_id, message: 'branch must be a unique repo + name combo' }

  belongs_to :repo
  has_many :burns
  has_many :findings
end
