# frozen_string_literal: true

module UrlParameters
  class ComponentsValidator < Dry::Validation::Contract
    params do
      required(:project_key).filled(:str?, min_size?: 1)
    end
  end
end
