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
  #     services:
  #       type: integer
  #       description: number of services
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
