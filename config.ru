require 'rubygems'
require './app'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'cache'
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = true
end

run App
