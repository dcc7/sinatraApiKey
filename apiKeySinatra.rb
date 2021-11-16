require "sinatra"
require "sinatra/reloader"
require "sinatra/cross_origin"
require "json"
require "httparty"
require 'rest-client'
require 'pry'



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

  data_in_JSON = results.parsed_response;

  labels = []
  longitudes = []
  latitudes = []
  route_ids = []

  data_in_JSON.each_line do |line|
    longitudes << line if line.include?("longitude")
    latitudes << line if line.include?("latitude")
    labels << line if line.include?("label")
    route_ids << line if line.include?("route_id")
  end

  # Need to clean up the data in each array.
  clean_longitudes = longitudes.map { |coordinate| coordinate[17..23].to_f }
  clean_latitudes = latitudes.map { |coordinate| coordinate[16..23].to_f }
  clean_labels_origin = labels.map { |label| label[20...-3].partition(" to ")[0] }
  clean_labels_destination = labels.map { |label| label[20...-3].partition(" to ")[2] }
  clean_labels_time = labels.map { |label| label[14...19] }
  clean_route_id = route_ids.map { |route_id| route_id.scan(/"([^"]*)"/)[0][0] }

  # loop through each and create an array of hashes.
  result_array = []

  i = 0
  loop do
    result_array[i] = {
      "id" => i + 1,
      "time" => clean_labels_time[i],
      "origin" => clean_labels_origin[i],
      "destination" => clean_labels_destination[i],
      "lat" => clean_latitudes[i],
      "lng" => clean_longitudes[i],
      "route_id" => clean_route_id[i],
    }

    i = i + 1
    if i == labels.length();
      break       # this will cause execution to exit the loop
    end
  end

  final_array = result_array.to_json

  final_array
end

get "/updates" do
  results = HTTParty.get("https://api.transport.nsw.gov.au/v1/gtfs/realtime/sydneytrains?debug=true", :headers => {
    "Authorization" => "apikey r8aueiiLOTKZSGo91lOOiktLtcySJeXaZyM5"
  })
  results.parsed_response

  data_in_JSON = results.parsed_response;


end
