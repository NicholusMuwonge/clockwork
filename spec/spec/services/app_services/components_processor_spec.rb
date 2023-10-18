# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppServices::ComponentsProcessor do
  describe '#call' do
    let(:project_key) { 'SP' }
    let(:processor) { described_class.new(project_key:) }

    context 'when the cached file is present' do
      before { allow(Rails.cache).to receive(:fetch).and_return('test_cached_file_path') }

      it 'sends the cached report and returns success' do
        processor_instance = AppServices::ComponentsProcessor.new({ project_key: })
        allow(processor_instance).to receive(:send_cached_report).and_call_original

        response = processor_instance.call

        expect(processor_instance).to have_received(:send_cached_report).once
        expect(response.success?).to be true
        expect(response.response_body).to eq(message: 'A report has been sent.')
      end
    end

    context 'when the cached file is not present' do
      before do
        allow(Rails.cache).to receive(:fetch)
        allow(AtlassianServices::FetchProjectComponents).to receive(:new).and_return(fetcher)
      end

      context 'when the component fetch is successful' do
        let(:fetcher) do
          response = ResponseHandler.structure_response([{ 'id' => 1, 'name' => 'UI' }], :success, true)
          instance_double(AtlassianServices::FetchProjectComponents,
                          call: response)
        end

        it 'processes components and returns success' do
          allow(processor).to receive(:process_components)
          response = processor.call
          expect(processor).to have_received(:process_components)
          expect(response.success?).to be true
        end
      end

      context 'when the component fetch is unsuccessful' do
        let(:fetcher) do
          response = ResponseHandler.structure_response({ 'errorMessages' => ['Not Found'] }, 404)
          instance_double(AtlassianServices::FetchProjectComponents,
                          call: response)
        end

        it 'returns an error response' do
          response = processor.call
          expect(response.success?).to be false
          expect(response.response_code).to eq(404)
          expect(response.response_body).to eq('errorMessages' => ['Not Found'])
        end
      end
    end
  end
end
