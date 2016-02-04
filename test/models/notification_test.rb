require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  test "notifies and destroys itself" do
    assert_difference('Notification.count', -1) do
      notification_email = mock('notification_email')
      notification_email.expects(:deliver_now).returns(true).once
      NotificationMailer.expects(:notification_email).returns(notification_email).once

      notifications(:one).burn = burns(:one).id
      notifications(:one).notify(burns(:one).id, {})
    end
  end
end
