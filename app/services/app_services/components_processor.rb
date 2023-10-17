# frozen_string_literal: true

module AppServices
  class ComponentsProcessor
    def initialize(url_params)
      @url_params = url_params
      @cached_file = Rails.cache.fetch("#{@url_params[:project_key]&.downcase}_components_file_cache")
      @batch_size = 1000
    end

    def call
      project_key = @url_params[:project_key]
      return send_cached_report if @cached_file.present?

      response = AtlassianServices::FetchProjectComponents.new(project_key:).call

      if response.success? && response.response_body.present?
        unassigned_components = response.response_body.select { |component| component['lead'].nil? }
        return blank_response if unassigned_components.blank?

        process_components(unassigned_components)
      end
      response
    end

    private

    def send_cached_report
      ReportMailer.send_report(I18n.t('components_report.subject'),
                               I18n.t('components_report.success_message'), @cached_file).deliver_later
      OpenStruct.new(success?: true, response_body: { message: 'Report sent.' })
    end

    def process_components(components, batch_size = @batch_size)
      components.each_slice(batch_size) do |components_batch|
        component_id_strings = Set.new(components_batch.map { |component| component['id'] }).join(',')
        FetchIssuesWorker.perform_async(component_id_strings, batch_size, @url_params[:project_key])
      end
    end

    def blank_response
      OpenStruct.new(success?: true, response_body: [])
    end
  end
end
