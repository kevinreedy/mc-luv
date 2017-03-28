require './lib/flight'
require './lib/segment'
require './lib/time_math'
require 'sinatra'

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

  post '/' do
    parsed_params = parse_search_params(params)

    date = parsed_params[:date]
    flights = Flight.search(parsed_params)

    erb :search_results, locals: { flights: flights, date: date }
  end
end
