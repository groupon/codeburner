class Notification < ActiveRecord::Base
  validates :burn, presence: true, uniqueness: { scope: :destination }
  validates :method, presence: true
  validates :destination, presence: true

  def notify burn_id, previous_stats
    return false unless self.burn.to_i == burn_id || self.burn == 'all'

    if self.method == 'email'
      NotificationMailer.notification_email(self.destination, burn_id, previous_stats).deliver_now
    end

    self.destroy unless self.burn == 'all'
  end

  def fail burn_id
    return false unless self.burn.to_i == burn_id || self.burn == 'all'

    if self.method == 'email'
      NotificationMailer.failure_email(self.destination, burn_id).deliver_now
    end

    self.destroy unless self.burn == 'all'
  end
end
