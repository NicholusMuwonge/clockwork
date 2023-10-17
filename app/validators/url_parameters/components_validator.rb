# frozen_string_literal: true

module UrlParameters
  class ComponentsValidator < Dry::Validation::Contract
    params do
      required(:project_key).value(:string)
    end
  end
end
