# frozen_string_literal: true

class SearchController < ApplicationController

  def index
    if (params[:engine].present? && (params[:engine] == 'both' || Search::AVAILABLE_ENGINES.include?(params[:engine]))) && params[:query].present?
      get_next_page
      render json: Search.get_results(engine: params[:engine], query: params[:query], next_page_bing: @next_page_bing, next_page_google: @next_page_google), status: :ok
    elsif params[:query].blank?
      render json: { error: I18n.t('errors.query_not_informed') }, status: :bad_request
    else
      render json: { error: I18n.t('errors.search_engine_not_available') }, status: :bad_request
    end
  rescue StandardError
    render json: { error: 'Try again in a few minutes' }, status: :internal_server_error
  end

  private

  def get_next_page
    if params[:next_page].present?
      @next_page_google = params[:next_page][:google]
      @next_page_bing = params[:next_page][:bing]
    end
  end
end
