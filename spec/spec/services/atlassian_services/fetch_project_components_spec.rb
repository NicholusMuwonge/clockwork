# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AtlassianServices::FetchProjectComponents do
  let(:url_params) { { project_key: 'SP' } }
  let(:fetcher) { described_class.new(url_params) }

  context 'when the component fetch is successful' do
    before do
      allow(Faraday::Connection).to receive(:new).and_return(instance_double(Faraday::Connection, get: response_double,
                                                                                                  adapter: nil))
      allow(JSON).to receive(:parse).and_return('[]')
    end

    let(:response_double) { instance_double(Faraday::Response, body: [], success?: true, status: 200) }

    it 'returns a success response' do
      response = fetcher.call

      expect(JSON).to have_received(:parse).with([])
      expect(response.success?).to be true
      expect(response.response_code).to eq(200)
      expect(response.response_body).to eq('[]')
    end
  end

  context 'when the component fetch is unsuccessful' do
    before do
      allow(Faraday::Connection).to receive(:new).and_return(instance_double(Faraday::Connection, get: response_double,
                                                                                                  adapter: nil))
      allow(JSON).to receive(:parse).and_return({ 'errorMessages' => ['Unexpected error.'] })
    end

    let(:response_double) do
      instance_double(Faraday::Response, body: JSON.dump({ 'errorMessages' => ['Unexpected error.'] }), success?: false,
                                         status: 500)
    end

    it 'returns a success response' do
      response = fetcher.call

      expect(JSON).to have_received(:parse).with(JSON.parse({ 'errorMessages' => ['Unexpected error.'] }))
      expect(response.success?).to be false
      expect(response.response_code).to eq(500)
    end
  end

  context 'when there is an error parsing the response' do
    before do
      allow(Faraday::Connection).to receive(:new).and_return(instance_double(Faraday::Connection, get: response_double,
                                                                                                  adapter: nil))
      allow(JSON).to receive(:parse).and_raise(JSON::ParserError.new('Parsing error'))
    end

    let(:response_double) { instance_double(Faraday::Response, body: 'response_body', success?: true, status: 200) }

    it 'returns a failure response' do
      response = fetcher.call

      expect(JSON).to have_received(:parse).with('response_body')
      expect(response.success?).to be false
      expect(response.response_code).to eq(422)
      expect(response.response_body).to eq('JSON parsing error: Parsing error')
    end
  end
end
