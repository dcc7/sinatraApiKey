require "sinatra"
require "sinatra/reloader"
require "json"
require "pry"
require "httparty"
require 'http'
require 'rest-client'

get "/" do

  results = HTTParty.get("https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/sydneytrains?debug=true", :headers => {
  "Authorization" => "apikey 2rZpu5FuWGpahN4FBDm5rz7CFBIddMjeYKwf"
})

results.parsed_response;

end
