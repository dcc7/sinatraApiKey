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
  labels = [];
  longituds = [];
  latituds = [];
  dataInJson = results.parsed_response;
  dataInJson.each_line do |line|
    longituds << line if line.include?("longitud")
    latituds << line if line.include?("latitud")
    labels << line if line.include?("label")
  end

    #Need to clean up the data in each array.
   cleanLongituds = longituds.map { |coordinate| coordinate[17..23].to_f }
   cleanLatituds = latituds.map { |coordinate| coordinate[16..23].to_f }
   cleanLabelsOrigin = labels.map { |stations| stations[20...-3].split.first }
   cleanLabelsDestination = labels.map { |stations| stations[20...-3].chomp("Station").split.last }
   #loop through each and create an array of hashes.

   # Empty object

   # trainTrips = {}
   resultArray = [];
  i = 0
  loop do
     resultArray[i]= {
       "origin" => cleanLabelsOrigin[i],
       "destination" => cleanLabelsDestination[i],
       "lat" => cleanLatituds[i],
       "lng" => cleanLongituds[i],
       "trip_id" => i+1,
     }
     # trainTrips[:origin] =  cleanLabelsOrigin[i]
     # trainTrips[:destination] = cleanLabelsDestination[i]
     # trainTrips[:latitud] = cleanLatituds[i]
     # trainTrips[:longitud] = cleanLongituds[i]
     # trainTrips[:trip_id] =  i+1
     # resultArray.push(trainTrips)
    i = i + 1
    if i == labels.length();
     break       # this will cause execution to exit the loop
   end
  end

finalArray = resultArray.to_json

finalArray


 # binding.pry
 end
