require "sinatra"
require "sinatra/reloader"
require "sinatra/cross_origin"
require "json"
require "httparty"
require 'rest-client'
require 'protobuf'
require 'google/transit/gtfs-realtime.pb'
require 'uri'
require 'net/http'
# require 'google-protobuf'


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

def get_results
  results = Net::HTTP.get(URI.parse("https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/nswtrains"), :headers => {
  "Authorization" => "apikey 2rZpu5FuWGpahN4FBDm5rz7CFBIddMjeYKwf"
})
  feed = Transit_realtime::FeedMessage.decode(results)
  trip_data = []
  for entity in feed.entity do
    if entity.field?(:trip_update)
      trip_data << entity.trip_update
    end
  end
  trip_data.to_json

end

get "/" do

  get_results
  # results.parsed_response;
end
