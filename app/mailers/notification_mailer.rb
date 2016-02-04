class NotificationMailer < ApplicationMailer

  def notification_email dest, burn_id, previous_stats
    @link_host = $app_config.mail.link_host[Rails.env]
    @burn = Burn.find(burn_id)
    @findings = Finding.burn_id(burn_id)
    @previous_stats = previous_stats
    @current_stats = CodeburnerUtil.get_service_stats(@burn.service_id)

    mail(to: dest, subject: "Codeburner Report: #{@burn.service.pretty_name} - #{@burn.revision}")
  end

  def failure_email dest, burn_id
    @burn = Burn.find(burn_id)

    mail(to: dest, subject: "Codeburner Failed: #{@burn.service.pretty_name} - #{@burn.revision}")
  end

end
