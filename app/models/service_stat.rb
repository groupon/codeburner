class ServiceStat < ActiveRecord::Base
  belongs_to :service
  has_paper_trail
end
