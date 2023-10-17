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
