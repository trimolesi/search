require 'rails_helper'

RSpec.describe Search, type: :model do
  it 'Get results from Google using query docker' do
    results = Search.get_results(engine: 'google', query: 'docker')

    expect(results.key?(:results)).to eq true
    expect(results[:results].size).to eq 6
  end

  it 'Get results from Bing using query docker' do
    results = Search.get_results(engine: 'bing', query: 'docker')

    expect(results.key?(:results)).to eq true
    expect(results[:results].size).to eq 8
  end

  it 'Get results from Both engines(Google and Bing) using query docker' do
    results = Search.get_results(engine: 'both', query: 'docker')

    expect(results.key?(:results)).to eq true
    expect(results[:results].size).to eq 14
  end

  it 'Unknow engine' do
    results = Search.get_results(engine: 'unknow', query: 'docker')

    expect(results).to be_nil
  end

end
