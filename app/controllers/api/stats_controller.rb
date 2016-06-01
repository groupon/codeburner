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
class Api::StatsController < ApplicationController
  # START ServiceDiscovery
  # resource: stats
  # description: Get statistics on number of burns/findings/etc.
  # method: GET
  # path: /stats
  #
  # response:
  #   name: stats
  #   description: Hash of statistics
  #   type: object
  #   properties:
  #     repos:
  #       type: integer
  #       description: number of repos
  #     burns:
  #       type: integer
  #       description: number of burns
  #     findings:
  #       type: integer
  #       description: number of findings
  #     files:
  #       type: integer
  #       description: number of files burned
  #     lines:
  #       type: integer
  #       description: numver of lines in files burned
  #
  # END ServiceDiscovery
  def index
    render(:json => Rails.cache.fetch('stats') { CodeburnerUtil.get_stats } )
  end

  def range
    render(:json => Rails.cache.fetch('histroy_range'){ CodeburnerUtil.get_history_range })
  end

  def resolution
    render(:json => CodeburnerUtil.history_resolution(Time.parse(params[:start_date]), Time.parse(params[:end_date])).to_i)
  end

  def history
    stats = CodeburnerUtil.get_history(params[:start_date], params[:end_date], params[:resolution])
    render(:json => stats)
  end

  def burns
    render(:json => CodeburnerUtil.get_burn_history(params[:start_date], params[:end_date]))
  end
end
