# frozen_string_literal: true

module Api
  module V1
    class ComponentsController < ApplicationController
      def sync_unassigned_components_with_issue_count
        confirmed_params = validate_params(components_params)
        project_key = confirmed_params['project_key']

        response = AppServices::ComponentsProcessor.new(project_key:).call

        if response.success?
          render json: { message: I18n.t('success_messages.report_generation_initiated') }
        else
          render json: { message: I18n.t('errors.something_unexpected') }, status: response.response_code
        end
      end

      private

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
