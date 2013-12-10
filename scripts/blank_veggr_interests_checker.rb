require 'rest-client'
require 'json'
require 'colorize'
require File.dirname(__FILE__)+'/../functional/lib/bifrost/token.rb'; include Token

domain = 'http://api.helloreverb.com'
ENV['env'] = 'prd'

headers = {:content_type => 'application/json', :accept => 'application/json'}

while true do

  list_of_interests = []

  #api_key = get_anon_token domain+"/v2"
  api_key = 'efb703bce849af39c9fa05695c264514ad0042ebf03f4ab4'

  res = RestClient.get "#{domain}/v2/trending/interests/social?skip=0&api_key=#{api_key}", headers
  interests = JSON.parse res
  puts "BLANK INTERESTS: INTERESTS #{interests['interests'].length}".red if interests['interests'].length < 1

  interests['interests'].each do |interest|
    list_of_interests << interest['value']
  end

  list_of_interests.each do |interest|
    res = RestClient.get "#{domain}/v2/interests/stream/social?interest=#{CGI::escape interest}&api_key=#{api_key}", headers
    data = JSON.parse res
    puts "BLANK INTEREST STREAM: #{data['tiles'].length} for #{interest}" if data['tiles'].length < 1
  end

  print ".".green

  sleep 5

end