module Searches
  class GoogleResults < ApplicationService
    attr_accessor :agent, :query, :page
    BASE_URL = "https://google.com/search"

    def initialize(query, page = nil)
      @agent = Mechanize.new
      @query = query
      @page = page
    end

    def call
      return nil if @query.blank?
      Rails.cache.fetch("google-#{@query}-#{@page}", expires_in: 1.hour) do
        params = { q: @query }
        #Param to paginate on google
        params[:start] = @page if @page.present?
        body_html = @agent.get(BASE_URL, params, BASE_URL, USER_AGENT).content
        parser(body_html)
      end
    rescue
      return nil
    end

    private

    def parser(body_html)
      # File.open('./tmp/test3.html', 'w').write(body_html.force_encoding('utf-8'))
      nokogiri_body = Nokogiri::HTML(body_html)
      result_stats = nokogiri_body.xpath('.//div[@id="result-stats"]').text
      #select divs that have the 'g' class and don't have the data-hveid attribute, as it could be an internal div of it and will duplicate the page
      results = nokogiri_body.xpath("//*[@class=\"g\"][not(@data-hveid)]")
      arr_results = []

      results.each do |result|
        hash_result = {}
        hash_result[:title] = result.search("div:first-child h3")&.first.text
        description = result.search('div:nth-child(1) > span')&.first&.parent
        next if description.blank?
        emphasis_tag = description.search('em')
        if (emphasis_tag.size > 1)
          hash_result[:description] = emphasis_tag.first.text
        else
          hash_result[:description] = description.text
        end
        hash_result[:url] = result.search('a').attr('href').text
        hash_result[:source] = "Google"
        arr_results << hash_result
      end
      #Check if page is present, if it's present add 10 to next page else the next page will be 10
      next_page = @page.present? ? @page.to_i + 10 : 10
      {
        result_stats: result_stats,
        next_page: { google: next_page },
        results: arr_results
      }
    end
  end
end