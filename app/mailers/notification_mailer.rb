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
class NotificationMailer < ApplicationMailer

  def notification_email dest, burn_id, previous_stats
    @link_host = Setting.email['link_host']
    @burn = Burn.find(burn_id)
    @findings = Finding.burn_id(burn_id)
    @previous_stats = previous_stats
    @current_stats = CodeburnerUtil.get_repo_stats(@burn.repo_id)

    mail(to: dest, subject: "Codeburner Report: #{@burn.repo.full_name} - #{@burn.revision}")
  end

  def failure_email dest, burn_id
    @burn = Burn.find(burn_id)

    mail(to: dest, subject: "Codeburner Failed: #{@burn.repo.full_name} - #{@burn.revision}")
  end

end
