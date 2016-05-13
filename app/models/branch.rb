class Branch < ActiveRecord::Base
  validates :name, uniqueness: { scope: :service_id, message: 'branch must be a unique service + name combo' }

  belongs_to :service
  has_many :burns
  has_many :findings
end
