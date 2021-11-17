require "sinatra"
require "sinatra/reloader"
require "sinatra/cross_origin"
require "json"
require "httparty"
require 'rest-client'
require 'pry'
require './routesJSON.rb'
require './stopsJSON.rb'

all_routes = $ROUTES
all_stops = $STOPS

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

  data_in_proto = results.parsed_response;

  labels = []
  longitudes = []
  latitudes = []
  route_ids = []
  trip_ids = []

  data_in_proto.each_line do |line|
    longitudes << line if line.include?("longitude")
    latitudes << line if line.include?("latitude")
    labels << line if line.include?("label")
    route_ids << line if line.include?("route_id")
    trip_ids << line if line.include?("trip_id")
  end

  # Need to clean up the data in each array.
  clean_longitudes = longitudes.map { |coordinate| coordinate[17..23].to_f }
  clean_latitudes = latitudes.map { |coordinate| coordinate[16..23].to_f }
  clean_labels_origin = labels.map { |label| label[20...-3].partition(" to ")[0] }
  clean_labels_destination = labels.map { |label| label[20...-3].partition(" to ")[2] }
  clean_labels_time = labels.map { |label| label[14...19] }
  clean_route_id = route_ids.map { |route_id| route_id.scan(/"([^"]*)"/)[0][0] }
  clean_trip_id = trip_ids.map { |trip_id| trip_id.scan(/"([^"]*)"/)[0][0] }

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
      "trip_id" => clean_trip_id[i]
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
  updates = HTTParty.get("https://api.transport.nsw.gov.au/v1/gtfs/realtime/sydneytrains?debug=true", :headers => {
    "Authorization" => "apikey r8aueiiLOTKZSGo91lOOiktLtcySJeXaZyM5"
  })

  updates_in_proto = updates.parsed_response;

  updates_array = []

  updates_in_proto.each_line do |line|
    updates_array << line if line.include?("trip_id")
    updates_array << line if line.include?("route_id")
    updates_array << line if line.include?("stop_id")
  end

  trip_ids = []
  route_ids = []
  stop_ids = []

  counter = -1
  updates_array.each do |id|

    if id.include?("trip")
      trip_ids << id
      counter += 1
      stop_ids[counter] = []
    elsif id.include?("route")
      route_ids << id
    else id.include?("stop")
      stop_ids[counter] << id
    end
  end


  trip_ids.map! { |trip_id| trip_id.scan(/"([^"]*)"/)[0][0] }
  route_ids.map! { |route_id| route_id.scan(/"([^"]*)"/)[0][0] }
  stop_ids.each do |stops|
    stops.map! { |stop_id| stop_id.scan(/"([^"]*)"/)[0][0] }
  end

  result_array = []
  i = 0

  while i < trip_ids.length
    result_array[i] = {
      "trip_id" => trip_ids[i],
      "route_id" => route_ids[i],
      "stop_ids" => stop_ids[i],
    }
    i += 1
  end
  final_array = result_array.to_json
  final_array
end
