# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'support@herocoders.com'
  layout 'mailer'
end
