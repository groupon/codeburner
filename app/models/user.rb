class User < ActiveRecord::Base
  has_many :tokens
  has_many :burns
  has_and_belongs_to_many :services

  enum role: [:user, :admin]
  after_initialize :set_default_role, :if => :new_record?

  def set_default_role
    self.role ||= :user
  end
end
