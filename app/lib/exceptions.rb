# frozen_string_literal: true

module Exceptions
  class InvalidApiParameters < StandardError
    attr_reader :validation_result

    def initialize(validation_result)
      super(validation_result)
      @validation_result = validation_result
    end
  end
end
