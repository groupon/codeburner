#
#The MIT License (MIT)
#
#Copyright (c) 2016, Groupon, Inc.
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
#
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
