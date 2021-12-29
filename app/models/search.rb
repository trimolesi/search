class Search

  AVAILABLE_ENGINES = ["google", "bing"].freeze
  def self.get_results(engine:, query:, next_page_bing: nil , next_page_google: nil)
    case engine
    when 'google'
      Searches::GoogleResults.call(query, next_page_google)
    when 'bing'
      Searches::BingResults.call(query, next_page_bing)
    when 'both'
      arr_results_google = Searches::GoogleResults.call(query, next_page_google)
      arr_results_bing = Searches::BingResults.call(query, next_page_bing)
      merge_results(arr_results_google, arr_results_bing)
    end
  end

  def self.merge_results(*results)
    results.compact!
    #Iterate over array to concat all results from all engines
    join_arr = results.flat_map { |result_engine| result_engine[:results] }
    #Remove duplicated results from differents engines, comparing same URL and Title.
    join_arr.uniq! { |result| result[:url] && result[:title] }
    #get next page from google and bing and add it to array
    next_page = results.map {|result| result[:next_page] }
    hash_merged = { next_page: next_page, results: join_arr}
    return hash_merged
  end
end
