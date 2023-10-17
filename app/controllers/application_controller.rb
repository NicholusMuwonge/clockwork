# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from Exceptions::InvalidApiParameters, with: :handle_invalid_api_params

  private

  def handle_invalid_api_params(exception)
    render json: {
      result: 'error',
      errors: exception.validation_result.errors.to_h
    }, status: :bad_request
  end
end
