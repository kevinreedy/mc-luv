require 'mechanize'
require 'csv'
require 'active_support'
require 'active_support/core_ext'

class TimeMath

  def self.datetime_for_airport(date, time, airport_code)
    Time.zone = airport_timezones[airport_code]
    Time.zone.parse("#{date} #{time}")
  end

  # get the list of IATA codes for airports Southwest services
  # cache them in a class variable, they don't change often
  def self.swa_airports
    VCR.use_cassette('swa_airports') do
      agent = Mechanize.new
      @@swa_airports ||= agent.get('https://www.southwest.com/html/air/airport-information.html')
                              .search('div.stationID').map(&:text).sort
    end
  end

  # get the locations, including timezones, of airports
  # cache them in a class variable, they don't change often
  def self.airport_data
    VCR.use_cassette('airport_data') do
      agent = Mechanize.new
      @@airport_data ||= agent.get('https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat')
                              .body.gsub(/\\"/,'""')
    end
  end

  def self.airport_merge
    headers = %w{openflight_id name city country iata_code icao_code latitude longitude altitude utc_offset dst tz type_of_port source}
    code_tz_mapping = {}
    CSV.parse(airport_data, headers: headers) do |info|
      code_tz_mapping[info['iata_code']] = info['tz'] if swa_airports.include?(info['iata_code'])
    end
    code_tz_mapping
  end

  # a lookup table for Southwest airport codes to their timezones
  def self.airport_timezones
    @@airport_timezones ||= airport_merge
  end

end
