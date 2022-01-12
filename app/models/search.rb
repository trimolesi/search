class Search

  AVAILABLE_ENGINES = ["google", "bing"].freeze

  def self.get_results(engine:, query:, page: 1)

    case engine
    when 'google'
      json = Searches::GoogleResults.call(query, page)
    when 'bing'
      json = Searches::BingResults.call(query, page)
    when 'both'
      arr_results_google = Searches::GoogleResults.call(query, page)
      arr_results_bing = Searches::BingResults.call(query, page)
      json = merge_results(page, arr_results_google, arr_results_bing)
    else
      return nil
    end
  end

  def self.merge_results(page, *results)
    results.compact!
    #Iterate over array to concat all results from all engines
    join_arr = results.flat_map { |result_engine| result_engine[:results] }

    #Remove duplicated results from differents engines, comparing same URL and Title.
    join_arr.uniq! { |result| result[:url] && result[:title] }

    hash_merged = { page: page.to_i, results_count_on_page: join_arr.size, results: join_arr }
    return hash_merged
  end
end
