# frozen_string_literal: true

module Searches
  # Service responsible to request a query from Google and return results
  class GoogleResults < ApplicationService
    attr_accessor :agent, :query, :page

    BASE_URL = 'https://google.com/search'

    def initialize(query, page = nil)
      super()
      @agent = Mechanize.new
      @query = query
      @page = page
    end

    def call
      return nil if @query.blank?

      Rails.cache.fetch("google-#{@query}-#{@page}", expires_in: 1.hour) do
        params = { q: @query }
        # Param to paginate on google
        params[:start] = @page if @page.present?
        body_html = @agent.get(BASE_URL, params, BASE_URL, USER_AGENT).content
        parser(body_html)
      end
    rescue StandardError
      nil
    end

    private

    def parser(body_html)
      # File.open('./tmp/test3.html', 'w').write(body_html.force_encoding('utf-8'))
      nokogiri_body = Nokogiri::HTML(body_html)
      result_stats = nokogiri_body.xpath('.//div[@id="result-stats"]').text
      # select divs that have the 'g' class and don't have the data-hveid attribute,
      # as it could be an internal div of it and will duplicate the page
      news_results = nokogiri_body.xpath('//*[@class="g"][not(@data-hveid)]')
      arr_results = []

      news_results.each do |news_div|
        hash_result = parse_div_with_news(news_div)
        arr_results << hash_result if hash_result.present?
      end
      # Check if page is present, if it's present add 10 to next page else the next page will be 10
      next_page = @page.present? ? @page.to_i + 10 : 10
      data_json(arr_results, next_page, result_stats)
    end

    def parse_div_with_news(news_div)
      title = news_div.search('div:first-child h3')&.first&.text
      description = news_div.search('div:nth-child(1) > span')&.first&.parent&.text
      url = news_div.search('a').attr('href').text

      # Not found div with description
      return nil if description.blank?

      create_hash_result_with_values(description, title, url)
    end

    def create_hash_result_with_values(description, title, url)
      hash_result = {}
      hash_result[:title] = title
      hash_result[:description] = description
      hash_result[:url] = url
      hash_result[:source] = 'Google'
      hash_result
    end

    def data_json(arr_results, next_page, result_stats)
      {
        result_stats: result_stats,
        next_page: { google: next_page },
        results: arr_results
      }
    end
  end
end
