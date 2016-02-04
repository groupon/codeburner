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
