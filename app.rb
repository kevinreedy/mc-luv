require 'sinatra'
require 'flyday'

# TODO: show Wifi
# TODO: show # of segments on direct flights
# TODO: css fomatting
# TODO: add date and search info to results page
# TODO: fix travel time w/ time zones

class App < Sinatra::Base
  def parse_search_params(params)
    {
      date: Date.parse(params[:date]),
      orig: params[:orig].split(/,\s*/).map(&:upcase),
      dest: params[:dest].split(/,\s*/).map(&:upcase),
      route_type: params[:route_type]
    }
  end

  def get_route_flights(params)
    route_type = params[:route_type]
    params.delete(:route_type)

    flyday = Flyday.new
    flights = flyday.search(params).select { |f| f.seats_left > 0 }
    flights.select! { |f| f.segments.size == 1 } if route_type == 'nonstop' || route_type == 'direct'
    flights.select! { |f| f.segments.first['numberOfStops'] == 0 } if route_type == 'nonstop'

    flights
  end

  get '/' do
    erb :search_form
  end

  post '/search' do
    parsed_params = parse_search_params(params)

    flights = []

    parsed_params[:orig].each do |orig_city|
      parsed_params[:dest].each do |dest_city|
        flights.concat(get_route_flights(
          date: parsed_params[:date],
          orig: orig_city,
          dest: dest_city,
          route_type: parsed_params[:route_type]
        ))
      end
    end

    flights.sort_by! { |flight| Time.parse(flight.takeoff_at) }

    erb :search_results, locals: { flights: flights }
  end
end
