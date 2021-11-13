require "sinatra"
require "sinatra/reloader"
require "sinatra/cross_origin"
require "json"
require "httparty"
require 'rest-client'

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
  "Authorization" => "apikey 2rZpu5FuWGpahN4FBDm5rz7CFBIddMjeYKwf"
})

results.parsed_response;

end
