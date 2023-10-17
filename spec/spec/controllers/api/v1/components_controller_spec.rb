# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ComponentsController, type: :controller do
  describe 'GET #sync_unassigned_components_with_issue_count' do
    let(:project_key) { 'SP' }

    context 'when project key is missing' do
      it 'returns a 400 Bad Request response' do
        get :sync_unassigned_components_with_issue_count
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when project key is present and valid' do
      before { allow(AppServices::ComponentsProcessor).to receive(:new).and_return(processor) }

      context 'when components are present' do
        let(:processor) do
          instance_double(AppServices::ComponentsProcessor, call: OpenStruct.new(success?: true, response_body: [{}]))
        end

        it 'initiates components processing and returns success message' do
          get :sync_unassigned_components_with_issue_count, params: { project_key: }
          expect(processor).to have_received(:call)
          expect(response).to have_http_status(:success)
          expect(JSON.parse(response.body)).to eq('message' => 'Sync initiated successfully.')
        end
      end

      context 'when components are not present' do
        let(:processor) do
          instance_double(AppServices::ComponentsProcessor, call: OpenStruct.new(success?: true, response_body: []))
        end

        it 'returns success message for empty components' do
          get :sync_unassigned_components_with_issue_count, params: { project_key: }
          expect(processor).to have_received(:call)
          expect(response).to have_http_status(:success)
          expect(JSON.parse(response.body)).to eq('message' => 'There are no components without a lead at the moment.')
        end
      end

      context 'when an unexpected error occurs' do
        let(:processor) do
          instance_double(AppServices::ComponentsProcessor,
                          call: OpenStruct.new(success?: false, response_body: { 'errorMessages' => ['Unexpected error.'] },
                                               response_code: :internal_server_error))
        end

        it 'returns an error message' do
          get :sync_unassigned_components_with_issue_count, params: { project_key: }
          expect(processor).to have_received(:call)
          expect(response).to have_http_status(:internal_server_error)
          expect(JSON.parse(response.body)).to eq('message' => 'Unexpected error.')
        end
      end

      context 'when an unexpected error occurs with no api provided error' do
        let(:processor) do
          instance_double(AppServices::ComponentsProcessor,
                          call: OpenStruct.new(success?: false, response_body: {},
                                               response_code: :internal_server_error))
        end

        it 'returns an error message' do
          get :sync_unassigned_components_with_issue_count, params: { project_key: }
          expect(processor).to have_received(:call)
          expect(response).to have_http_status(:internal_server_error)
          expect(JSON.parse(response.body)).to eq('message' => 'Something unexpected happened.')
        end
      end
    end
  end
end
