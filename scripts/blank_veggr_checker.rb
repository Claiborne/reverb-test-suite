require 'rest-client'
require 'json'
require 'colorize'
require File.dirname(__FILE__)+'/../functional/lib/bifrost/token.rb'; include Token

domain = 'http://api.helloreverb.com'
ENV['env'] = 'prd'

headers = {:content_type => 'application/json', :accept => 'application/json'}

while true do

  #api_key = get_anon_token domain+"/v2"
  api_key = 'efb703bce849af39c9fa05695c264514ad0042ebf03f4ab4'

  res = RestClient.get "#{domain}/v2/trending/tiles/social?skip=0&api_key=#{api_key}", headers
  tiles = JSON.parse res
  puts "BLANK TILES: TILES #{tiles['tiles'].length}".red if tiles['tiles'].length < 1

  res = RestClient.get "#{domain}/v2/trending/interests/social?skip=0&api_key=#{api_key}", headers
  interests = JSON.parse res
  puts "BLANK INTERESTS: INTERESTS #{interests['interests'].length}".red if interests['interests'].length < 1

  print ".".green

  sleep 1*40

end
