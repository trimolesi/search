# frozen_string_literal: true

module Searches
  # Service responsible to request a query from Bing and return results
  class BingResults < ApplicationService
    attr_accessor :agent, :query, :page

    BASE_URL = 'https://www.bing.com/search'

    def initialize(query, page = nil)
      super()
      @agent = Mechanize.new
      @query = query
      @page = page
    end

    def call
      return nil if @query.blank?

      Rails.cache.fetch("bing-#{@query}-#{@page}", expires_in: 1.hour) do
        params = { q: @query }
        # Param to paginate on bing
        params[:first] = paginate if @page.present? and @page.to_i != 1
        body_html = @agent.get(BASE_URL, params, BASE_URL, USER_AGENT).content
        parser(body_html)
      end
    rescue StandardError
      nil
    end

    private

    def parser(body_html)
      # File.open('./tmp/test-bing.html', 'w').write(body_html.force_encoding('utf-8'))
      nokogiri_body = Nokogiri::HTML(body_html)

      result_stats = nokogiri_body.xpath('.//*[@class="sb_count"]').text

      news_results = nokogiri_body.xpath('//*[@class="b_algo"]')

      arr_results = []
      news_results.each do |news_div|
        hash_result = parse_div_with_news(news_div)
        arr_results << hash_result if hash_result.present?
      end
      # Check if page is present, if it's present add the size of result return to next page
      # else the next page will be the size of results returned
      next_page = @page.present? ? @page.to_i + arr_results.size : arr_results.size
      data_json(result_stats, arr_results)
    end

    def parse_div_with_news(news_div)
      title = news_div.search('h2')&.first&.text
      description = news_div.search('.b_caption > p')&.first&.text

      description = news_div.search('.b_paractl')&.first&.text if description.blank?

      url = news_div.search('cite').text

      return nil if title.blank? || description.blank? || url.blank?

      create_hash_result_with_values(description, title, url)
    end

    def create_hash_result_with_values(description, title, url)
      hash_result = {}
      hash_result[:title] = title
      hash_result[:description] = description
      hash_result[:url] = url
      hash_result[:source] = 'Bing'
      hash_result
    end

    def data_json(result_stats, arr_results)
      {
        result_stats: result_stats,
        results_count_on_page: arr_results.size,
        page: @page.to_i,
        results: arr_results
      }
    end

    def paginate
      return (@page.to_i * 10 - 1) - 10
    end
  end
end
