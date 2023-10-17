# frozen_string_literal: true

class ResponseHandler
  def self.handle_json_parser_error(error)
    OpenStruct.new(success?: false, response_code: 422, response_body: "JSON parsing error: #{error.message}")
  end

  def self.handle_invalid_uri_error(_error)
    OpenStruct.new(success?: false, response_code: 422, response_body: { 'errorMessages' => ['Invalid URI.'] })
  end

  def self.handle_response(body, status, response)
    response_body = JSON.parse(body)
    if response.success?
      OpenStruct.new(success?: true, response_code: status, response_body:)
    else
      OpenStruct.new(success?: false, response_code: status, response_body:)
    end
  end
end
