module Searches
  class BingResults < ApplicationService
    attr_accessor :agent, :query, :page
    BASE_URL = "https://www.bing.com/search"

    def initialize(query, page = nil)
      @agent = Mechanize.new
      @query = query
      @page = page
    end

    def call
      return nil if @query.blank?
      # query = CGI::escape(query)
      Rails.cache.fetch("bing-#{@query}-#{@page}", expires_in: 1.hour) do
        params = { q: @query }
        #Param to paginate on bing
        params[:first] = @page if @page.present?
        body_html = @agent.get(BASE_URL, params, BASE_URL, USER_AGENT).content
        parser(body_html)
      end
    rescue
      return nil
    end

    private

    def parser(body_html)
      # File.open('./tmp/test-bing.html', 'w').write(body_html.force_encoding('utf-8'))
      nokogiri_body = Nokogiri::HTML(body_html)
      result_stats = nokogiri_body.xpath('.//*[@class="sb_count"]').text
      results = nokogiri_body.xpath("//*[@class=\"b_algo\"]")
      arr_results = []
      results.each do |result|
        hash_result = {}
        title = result.search("h2")&.first&.text
        description = result.search('.b_caption > p')&.first&.text

        if (description.blank?)
          description = result.search('.b_paractl')&.first&.text
        end
        url = result.search('cite').text
        unless (title.blank? || description.blank? || url.blank?)
          hash_result[:title] = title
          hash_result[:description] = description
          hash_result[:url] = url
          hash_result[:source] = "Bing"
          arr_results << hash_result
        end
      end
      #Check if page is present, if it's present add the size of result return to next page else the next page will be the size
      #of results returned
      next_page = @page.present? ? @page.to_i + arr_results.size : arr_results.size
      return {
        result_stats: result_stats,
        next_page: { bing: next_page },
        results: arr_results
      }

    end
  end

end
