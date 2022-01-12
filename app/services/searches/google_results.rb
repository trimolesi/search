# frozen_string_literal: true

module Searches
  # Service responsible to request a query from Google and return results
  class GoogleResults < ApplicationService
    attr_accessor :agent, :query, :page

    BASE_URL = 'https://google.com/search'

    def initialize(query, page = 1)
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
        params[:start] = paginate if @page.present? and @page.to_i != 1
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

      data_json(arr_results, result_stats)
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

    def data_json(arr_results, result_stats)
      {
        result_stats: result_stats,
        results_count_on_page: arr_results.size,
        page: @page.to_i,
        results: arr_results
      }
    end

    def paginate
      return (@page.to_i - 1) * 10
    end
  end
end
