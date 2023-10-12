# frozen_string_literal: true

module Api
  module V1
    class HomeController < ApplicationController
      def index
        render json: { message: I18n.t('welcome_message') }
      end
    end
  end
end
