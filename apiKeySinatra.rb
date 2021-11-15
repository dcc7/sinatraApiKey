require "sinatra"
require "sinatra/reloader"
require "sinatra/cross_origin"
require "json"
require "httparty"
require 'rest-client'
require 'pry'
require 'protobuf'
require 'google/transit/gtfs-realtime.pb'
require 'uri'

set :bind, '0.0.0.0'
configure do
  enable :cross_origin
end
before do
  response.headers['Access-Control-Allow-Origin'] = '*'
end

options "*" do
  response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
  response.headers["Access-Control-Allow-Origin"] = "*"
  200
end

get "/" do
  results = HTTParty.get("https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/sydneytrains?debug=true", :headers => {
    "Authorization" => "apikey r8aueiiLOTKZSGo91lOOiktLtcySJeXaZyM5"
  })

  data = results.parsed_response;
end

#
# def get_results
#   results = HTTParty.get(URI.parse("https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/sydneytrains"), :headers => {
#     "Authorization" => "apikey r8aueiiLOTKZSGo91lOOiktLtcySJeXaZyM5"
#   })
#
#
#   feed = Transit_realtime::FeedMessage.decode(results)
#   trip_data = []
#   for entity in feed.entity do
#     if entity.field?(:position)
#       trip_data << entity.position
#     end
#   end
#   trip_data.to_json
# end
#
# get "/" do
#   get_results
#     binding.pry
# end
