require './lib/flight'
require './lib/segment'
require './lib/time_math'
require 'sinatra'
require 'json'

class App < Sinatra::Base
  def parse_search_params(params)
    {
      date: Date.parse(params[:date]),
      orig: params[:orig].split(/,\s*/).map(&:upcase),
      dest: params[:dest].split(/,\s*/).map(&:upcase),
      route_type: params[:route_type]
    }
  end

  get '/' do
    erb :search_form
  end

  get '/search' do
    parsed_params = parse_search_params(params)

    date = parsed_params[:date]
    flights = Flight.search(parsed_params)

    erb :search_results, locals: { flights: flights, date: date }
  end

  post '/nearby_prices' do
    parsed_params = parse_search_params(params)
    days = params[:days].to_i
    date = parsed_params[:date]

    prices = {}

    (date-days..date+days).to_a.each do |date|
      parsed_params[:date] = date
      begin
        prices[date.iso8601] = Flight.search(parsed_params).map{ |f| f.price_range.split(/-/).first.to_i }.min
      rescue Mechanize::ResponseCodeError
        prices[date.iso8601] = 0
      end
    end

    content_type :json
    prices.to_json
  end
end
