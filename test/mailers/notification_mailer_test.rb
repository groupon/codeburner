require 'test_helper'

class NotificationMailerTest < ActionMailer::TestCase
  # previous_stats = {
  #   :open_findings => 0,
  #   :filtered_findings => 0,
  #   :published_findings => 0,
  #   :hidden_findings => 0,
  #   :total_findings => 0
  # }

  # def burn_ids
  #   burn_ids = []
  #   burns.each { |burn| burn_ids << burn.id }
  #   return burn_ids
  # end

  # test "notification_email" do
  #   email = NotificationMailer.notification_email(notifications(:one).destination, burns(:one).id, @previous_stats)

  #   assert_emails 1 do
  #     email.deliver_now
  #   end

  #   assert_equal read_fixture('notification_email').join, email.body.to_s
  # end

  # test "fails on invalid burn id" do
  #   assert_raises(ActiveRecord::RecordNotFound) do
  #     NotificationMailer.notification_email(notifications(:one).destination, ([1...1000] - burn_ids).sample, @previous_stats).deliver_now
  #   end
  # end
end
