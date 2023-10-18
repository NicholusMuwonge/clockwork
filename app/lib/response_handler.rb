# frozen_string_literal: true

class ResponseHandler
  def self.handle_json_parser_error(error)
    response_body = "JSON parsing error: #{error.message}"
    response_code = 422
    structure_response(response_body, response_code)
  end

  def self.handle_invalid_uri_error(_error)
    response_body = { 'errorMessages' => ['Invalid URI.'] }
    response_code = 422
    structure_response(response_body, response_code)
  end

  def self.structure_response(response_body, response_code = nil, success = false, additional_properties = {})
    default_properties = { success?: success, response_code:, response_body: }
    OpenStruct.new(default_properties.merge(additional_properties))
  end

  def self.handle_response(body, status, response)
    response_body = JSON.parse(body)
    if response.success?
      structure_response(response_body, status, true)
    else
      structure_response(response_body, status)
    end
  end
end
