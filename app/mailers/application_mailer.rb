class ApplicationMailer < ActionMailer::Base
  default from: $app_config.mail.from
  layout 'mailer'
end
