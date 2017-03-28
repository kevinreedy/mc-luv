require 'flyday'

class Flight
  attr_accessor :takeoff_at, :land_at, :orig, :dest, :travel_time, :price_range,
                :segments, :segments_path

  def initialize(flyday_flight, date)
    @orig       = flyday_flight.orig
    @dest       = flyday_flight.dest
    @takeoff_at = TimeMath.datetime_for_airport(date, flyday_flight.takeoff_at, flyday_flight.orig)
    @land_at    = TimeMath.datetime_for_airport(date, flyday_flight.land_at, flyday_flight.dest)
    @travel_time = Time.at(land_at - takeoff_at).utc
    @segments   = flyday_flight.segments.map { |s| Segment.new s }
    @segments_path = flyday_flight.segments_path
    @price_range  = flyday_flight.price_range
  end

  def self.get_route_flights(params)
    route_type = params[:route_type]
    params.delete(:route_type)

    flyday = Flyday.new
    flights = flyday.search(params).select { |f| f.seats_left > 0 }
    flights.select! { |f| f.segments.size == 1 } if route_type == 'nonstop' || route_type == 'direct'
    flights.select! { |f| f.segments.first['numberOfStops'] == 0 } if route_type == 'nonstop'

    flights.map { |f| Flight.new f, params[:date] }
  end

  def self.search(params)
    flights = []
    params[:orig].each do |orig_city|
      params[:dest].each do |dest_city|
        flights.concat(get_route_flights(
          date: params[:date],
          orig: orig_city,
          dest: dest_city,
          route_type: params[:route_type]
        ))
      end
    end
    flights.sort_by! { |flight| flight.takeoff_at }
  end
end
