# frozen_string_literal: true

class ReportMailer < ApplicationMailer
  def send_report(subject, message, file_path = '')
    @message = message
    attachments['unassigned_components_report.txt'] = File.read(file_path) if file_path.present?
    mail(subject:)
  end
end
