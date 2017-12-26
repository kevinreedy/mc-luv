require 'rubygems'
require 'mechanize'
require 'vcr'

task :update_cache do
  VCR.configure do |config|
    config.cassette_library_dir = 'cache'
    config.hook_into :webmock
  end

  VCR.use_cassette('swa_airports', record: :all) do
    agent = Mechanize.new
    agent.get('https://www.southwest.com/html/air/airport-information.html')
  end

  VCR.use_cassette('airport_data', record: :all) do
    agent = Mechanize.new
    agent.get('https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat')
  end

  puts "Don't forget to commit the new cache updates!"
end
