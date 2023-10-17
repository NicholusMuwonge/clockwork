# frozen_string_literal: true

module AtlassianServices
  class FetchProjectIssues
    def initialize(url_params)
      @url_params = url_params
      @api_url = Rails.application.config_for(:atlassian)['api_url']
    end

    def call
      start_at = @url_params[:start_at] || 0
      max_results = @url_params[:max_results] || 100
      jql = @url_params[:jql]

      url = "#{@api_url}/search"
      params = {
        jql:,
        maxResults: max_results,
        startAt: start_at,
        fields: @url_params[:fields]
      }

      request = Faraday.new(url:, params:) do |faraday|
        faraday.adapter Faraday.default_adapter
      end

      body = request.get.body
      status = request.get.status

      handle_response(body, status, request.get)
    end

    private

    def handle_response(body, status, response)
      response_body = JSON.parse(body)
      if response.success?
        OpenStruct.new(success?: true, response_code: status, response_body:)
      else
        OpenStruct.new(success?: false, response_code: status, response_body:)
      end
    end
  end
end
