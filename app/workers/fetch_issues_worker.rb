# frozen_string_literal: true

class FetchIssuesWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2, queue: :default

  def perform(component_batch, batch_size, project_key)
    file_path = Rails.root.join('tmp', "#{project_key&.downcase}_components_issues_output.txt")

    unassigned_components_issues = map_issues_to_unassigned_components(component_batch, batch_size, project_key)
    return unless unassigned_components_issues.present?

    write_to_file(file_path, project_key, unassigned_components_issues)
    send_report(file_path) if file_path.present?
  end

  private

  def map_issues_to_unassigned_components(component_batch, batch_size, project_key)
    components_without_lead = []
    component_batch.split(',').each_slice(batch_size) do |batch|
      components_without_lead = fetch_issues_for_component_batch(batch, project_key)
    end
    components_without_lead
  end

  def write_title(file)
    file.puts("\n\n** Timestamp: #{Time.current} **\n\n")
  end

  def write_component_issues(file, components_without_lead)
    components_without_lead.each do |component|
      file.puts("#{component[:name]} component has #{component[:count]} available issues.")
    end
  end

  def cache_file_path(file_path, project_key)
    Rails.cache.write("#{project_key&.downcase}_components_file_cache", file_path.to_s, expires_in: 4.hours)
  end

  def write_to_file(file_path, project_key, components_without_lead)
    mode = File.exist?(file_path) ? 'a' : 'w'

    File.open(file_path, mode) do |file|
      write_title(file)
      write_component_issues(file, components_without_lead)
    end
    cache_file_path(file_path, project_key)
  end

  def fetch_issues_for_component_batch(batch, project_key)
    component_ids_set = Set.new(batch.map { |component| component })

    Enumerator.new do |yielder|
      loop do
        response = fetch_project_issues(jql(project_key, component_ids_set))

        break unless response.success?

        issues = response.response_body['issues']

        break if issues.empty?

        component_count = component_issue_count(issues, component_ids_set)
        component_count.each { |name, count| yielder << { name:, count: } }

        break unless more_results?(response)
      end
    rescue Faraday::TimeoutError => e
      log_timeout_error(e)
    rescue StandardError => e
      log_standard_error(e)
    end
  end

  def fetch_project_issues(jql)
    AtlassianServices::FetchProjectIssues.new(jql:, max_results: 100, start_at: 0, fields: 'components').call
  end

  def jql(project_key, component_ids_set)
    "project=#{project_key} AND component['id'] IN (#{component_ids_set.to_a.join(',')})"
  end

  def more_results?(response)
    (response.response_body['maxResults'] + response.response_body['startAt']) < response.response_body['total']
  end

  def log_timeout_error(error)
    Rails.logger.error("API Timeout Error in fetch_issues_for_component_batch: #{error.message}")
  end

  def log_standard_error(error)
    Rails.logger.error(error.backtrace.join("\n"))
  end

  def component_issue_count(issues, component_ids_set)
    component_count = Hash.new(0)
    issues.each do |issue|
      components = issue['fields']['components']
      components.each do |component|
        if component_ids_set.include?(component['id'])
          component_name = component['name']
          component_count[component_name] += 1
        end
      end
    end
    component_count
  end

  def send_report(file_path)
    ReportMailer.send_report(I18n.t('components_report.subject'),
                             I18n.t('components_report.success_message'), file_path.to_s).deliver_later
  end
end
