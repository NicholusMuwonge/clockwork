# frozen_string_literal: true

module Api
  module V1
    class ComponentsController < ApplicationController
      def sync_unassigned_components_with_issue_count
        confirmed_params = validate_params(components_params)
        project_key = confirmed_params['project_key']&.strip

        response = AppServices::ComponentsProcessor.new(project_key:).call

        handle_response(response)
      end

      private

      def handle_response(response)
        body = response.response_body
        success = response.success?
        if success && body.blank?
          render json: { message: I18n.t('success_messages.blank_unassigned_components') }
        elsif success && body.present?
          render json: { message: I18n.t('success_messages.report_generation_initiated') }
        else
          render json: { message: body['errorMessages']&.join("\n") || I18n.t('errors.something_unexpected') },
                 status: response.response_code
        end
      end

      def validate_params(components_params)
        validated_result = UrlParameters::ComponentsValidator.new.call(components_params.to_h)
        raise Exceptions::InvalidApiParameters, validated_result unless validated_result.success?

        validated_result
      end

      def components_params
        params.permit(:project_key)
      end
    end
  end
end
