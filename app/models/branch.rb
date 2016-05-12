class Branch < ActiveRecord::Base
  belongs_to :service
  has_many :burns
end
