# frozen_string_literal: true

module AtlassianServices
  class FetchProjectComponents
    def initialize(url_params)
      @url_params = url_params
      @api_url = Rails.application.config_for(:atlassian)['api_url']
    end

    def call
      project_key = @url_params[:project_key]
      url = "#{@api_url}/project/#{project_key}/components"
      request = Faraday.new(url:) do |faraday|
        faraday.adapter Faraday.default_adapter
      end

      body = request.get.body
      status = request.get.status

      ResponseHandler.handle_response(body, status, request.get)
    rescue URI::InvalidURIError => e
      ResponseHandler.handle_invalid_uri_error(e)
    rescue JSON::ParserError => e
      ResponseHandler.handle_json_parser_error(e)
    end
  end
end
