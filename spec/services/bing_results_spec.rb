require 'rails_helper'

RSpec.describe 'Service BingResults', type: :request do
  describe 'Call Service Bing Results' do
    it 'Timeout on Bing request' do
      params = 'docker'
      stub_request(:get, "#{Searches::BingResults::BASE_URL}?q=#{params}").to_timeout

      service = Searches::BingResults.call(params)

      expect(service).to eq(nil)
    end

    it 'valid request with query: docker' do
      params = 'docker'

      service = Searches::BingResults.call(params)

      expect(service.key?(:results)).to eq true
      expect(service[:results].size).to eq 8
    end

    it 'check data returned' do
      params = 'docker'

      service = Searches::BingResults.call(params)
      result = service[:results].first

      expect(service.key?(:results)).to eq true
      expect(result[:title]).not_to be_nil
      expect(result[:description]).not_to be_nil
      expect(result[:url]).not_to be_nil
      expect(service[:results].size).to eq 8
    end

  end
end
