# frozen_string_literal: true

require 'swagger_helper'

describe 'Components functionality' do
  path '/api/v1/components/unassigned' do
    get 'Generates reports for unassigned components and the issues that belong to them.' do
      tags 'UnassignedComponents'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :project_key, in: :query, type: :string, required: true, minLength: 1
      response '200', 'components loaded' do
        let(:project_key) { 'SP' }
        run_test!
      end

      response '400', 'bad request' do
        let(:project_key) {}
        run_test! do |response|
          data = JSON.parse(response.body)

          expect(data['result']).to eq('error')
          expect(response.status).to eq(400)
        end
      end

      response '404', 'bad request' do
        let(:project_key) { 'some_random_project' }
        run_test! do |response|
          data = JSON.parse(response.body)

          expect(data['message']).to eq("No project could be found with key 'some_random_project'.")
          expect(response.status).to eq(404)
        end
      end
    end
  end
end
