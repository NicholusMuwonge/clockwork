# frozen_string_literal: true

class FetchIssuesWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2, queue: :default

  def perform(component_batch, batch_size, project_key)
    file_path = Rails.root.join('tmp', "#{project_key&.downcase}_components_issues_output.txt")

    unassigned_components_issues = map_issues_to_unassigned_components(component_batch, batch_size, project_key)
    return unless unassigned_components_issues.present?

    AppServices::FileProcessor.new.write_to_file(file_path, project_key, unassigned_components_issues)
  end

  private

  def map_issues_to_unassigned_components(component_batch, batch_size, project_key)
    components_without_lead = []
    component_batch.split(',').each_slice(batch_size) do |batch|
      result = fetch_issues_for_component_batch(batch, project_key)
      components_without_lead += result.to_a
    end
    components_without_lead
  end

  def fetch_issues_for_component_batch(batch, project_key)
    component_ids = batch.map { |component| component }

    Enumerator.new do |yielder|
      loop do
        jql_query = jql(project_key, component_ids)
        response = fetch_project_issues(jql_query)

        break unless response.success?

        issues = response.response_body['issues']

        break if issues.empty?

        component_count = component_issue_count(issues, component_ids)
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

  def jql(project_key, component_ids)
    "project=#{project_key} AND component['id'] IN (#{component_ids.to_a.join(',')})"
  end

  def more_results?(response)
    body = response.response_body
    (body['maxResults'] + body['startAt']) < body['total']
  end

  def log_timeout_error(error)
    Rails.logger.error("API Timeout Error in fetch_issues_for_component_batch: #{error.message}")
  end

  def log_standard_error(error)
    Rails.logger.error(error.backtrace.join("\n"))
  end

  def component_issue_count(issues, component_ids)
    component_count = Hash.new(0)
    issues.each do |issue|
      components = issue['fields']['components']
      components.each do |component|
        if component_ids.include?(component['id'])
          component_name = component['name']
          component_count[component_name] += 1
        end
      end
    end
    component_count
  end
end
