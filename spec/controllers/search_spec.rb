# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SearchController do
  describe 'GET /search' do
    it 'valid request with google' do
      params = { engine: 'google', query: 'docker' }

      get :index, params: params
      hash = JSON.parse(response.body)

      expect(response).to have_http_status(:success)
      expect(hash.key?('results')).to eq true
      expect(hash['results'].size).to eq 6
    end

    it 'valid request with bing' do
      params = { engine: 'bing', query: 'docker' }

      get :index, params: params
      hash_response = JSON.parse(response.body)

      expect(response).to have_http_status(:success)
      expect(hash_response.key?('results')).to eq true
      expect(hash_response['results'].size).to eq 8
    end

    it 'valid request with both engines' do
      params = { engine: 'both', query: 'docker' }

      get :index, params: params
      hash_response = JSON.parse(response.body)

      expect(response).to have_http_status(:success)
      expect(hash_response.key?('results')).to eq true
      expect(hash_response['results'].size).to eq 14
    end

    it 'unknow engine' do
      params = { engine: 'otherengine', query: 'docker' }

      get :index, params: params
      hash_response = JSON.parse(response.body)

      expect(response).to have_http_status(:bad_request)
      expect(hash_response.key?('error')).to eq true
      expect(hash_response['error']).to eq I18n.t('errors.search_engine_not_available')
    end

    it 'invalid request' do
      params = { engine: 'google', query: '' }

      get :index, params: params
      hash_response = JSON.parse(response.body)

      expect(response).to have_http_status(:bad_request)
      expect(hash_response.key?('error')).to eq true
      expect(hash_response['error']).to eq I18n.t('errors.query_not_informed')
    end
  end
end
