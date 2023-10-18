# frozen_string_literal: true

module AppServices
  class ComponentsProcessor
    def initialize(url_params)
      @url_params = url_params
      @project_key = url_params[:project_key]
      file_cache_key = CacheHandler.file_cache_name(@project_key)
      @cached_file = Rails.cache.fetch(file_cache_key)
      @batch_size =  Rails.application.config_for(:atlassian)['in_operator_batch_limit']
    end

    def call
      return send_cached_report if @cached_file.present?

      response = AtlassianServices::FetchProjectComponents.new(project_key: @project_key).call

      if response.success? && response.response_body.present?
        unassigned_components = response.response_body.select { |component| component['lead'].nil? }
        return ResponseHandler.structure_response([], 200, true) if unassigned_components.blank?

        process_components(unassigned_components)
      end
      response
    end

    private

    def send_cached_report
      ReportMailer.send_report(I18n.t('components_report.subject'),
                               I18n.t('components_report.success_message'),
                               @cached_file).deliver_later
      response_body = { message: I18n.t('success_messages.report_sent') }
      ResponseHandler.structure_response(response_body, 200, true)
    end

    def process_components(components, batch_size = @batch_size)
      components.each_slice(batch_size) do |components_batch|
        component_id_strings = (components_batch.map { |component| component['id'] }).uniq&.join(',')

        FetchIssuesWorker.perform_async(component_id_strings, batch_size, @project_key)
      end
    end
  end
end
