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
    acc_results = counter_results_json(engine, json, page, query)
    acc_results.merge(json)
  end

  private

  def self.merge_results(page, *results)
    results.compact!
    #Iterate over array to concat all results from all engines
    join_arr = results.flat_map { |result_engine| result_engine[:results] }

    #Remove duplicated results from differents engines, comparing same URL and Title.
    join_arr.uniq! { |result| result[:url] && result[:title] }

    hash_merged = { page: page.to_i, results_count_on_page: join_arr.size, results: join_arr }
    return hash_merged
  end

  def self.increment_counter_of_results_to_page(engine:, query:, page: 1, size:)
    previous_page = page == 1 ? page : page.to_i - 1
    previous_acc_page = Rails.cache.fetch("counter-results-#{engine}-#{query}-#{previous_page}")

    size = Rails.cache.fetch("counter-results-#{engine}-#{query}-#{page}", expires_in: 1.hour) do
      previous_acc_page ||= 0
      previous_acc_page + size
    end
    size
  end

  def self.counter_results_json(engine, json, page, query)
    results_size = json[:results].size if json.present?
    acc_results = Search.increment_counter_of_results_to_page(query: query, engine: engine, page: page, size: results_size)
    { counter_results: acc_results }
  end
end
