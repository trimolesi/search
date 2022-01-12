# frozen_string_literal: true

module Api
  module V1
    # API Controller responsible to request a query to Bing or Google and return a response in json
    class SearchController < ApplicationController
      before_action :validate_request, :set_page

      api :GET, '/v1/search/:engine/:query', 'Search on google, bing or both and return the data.'
      param :engine, String, desc: 'Which engine to search. <br> Possible values are: google, bing or both',
            required: true
      param :query, String, desc: 'Query to search', required: true

      def index
        render json: Search.get_results(engine: params[:engine], query: params[:query],
                                        page: @page),
               status: :ok
      rescue StandardError
        render json: { error: 'Try again in a few minutes' }, status: :internal_server_error
      end

      private

      def set_page
        @page = params[:page]
        @page ||= 1
      end

      def validate_request
        unless params[:engine].present? &&
          (params[:engine] == 'both' || Search::AVAILABLE_ENGINES.include?(params[:engine]))
          render json: { error: I18n.t('errors.search_engine_not_available') }, status: :bad_request and return
        end
        return true if !params[:query].blank?

        render json: { error: I18n.t('errors.query_not_informed') }, status: :bad_request and return
      end
    end
  end
end
