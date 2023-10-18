# frozen_string_literal: true

module AppServices
  class FileProcessor
    def write_to_file(file_path, project_key, components_without_lead)
      mode = File.exist?(file_path) ? 'a' : 'w'

      File.open(file_path, mode) do |file|
        write_title(file) if mode == 'w'
        write_component_issues_with_count(file, components_without_lead)
      end
      CacheHandler.cache_file_path(file_path, project_key)
      send_report(file_path) if file_path.present?
    end

    private

    def write_title(file)
      formated_time = Time.now.strftime('%Y-%m-%d %H:%M:%S')
      file.puts("\n\n** Timestamp: #{formated_time} **\n\n")
    end

    def write_component_issues_with_count(file, components_without_lead)
      components_without_lead.each do |component|
        file.puts("#{component[:name]} component has #{component[:count]} available issues.")
      end
    end

    def send_report(file_path)
      ReportMailer.send_report(I18n.t('components_report.subject'),
                               I18n.t('components_report.success_message'), file_path.to_s).deliver_later
    end
  end
end
