require "sinatra"
require "sinatra/reloader"
require "json"

get "/" do
  content_type :json
  {api_key: "apikey WNcx5DP0AXfU0B3FZkQxs6FUrpKzAkpZy70C"}.to_json
end
