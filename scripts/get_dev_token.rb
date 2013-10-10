require 'rest_client'
require 'json'

CLIENTID = '51561484e4b0edfcfec11627'
endpoint = "https://dev-api.helloreverb.com/v2/account/ohai?clientId=#{CLIENTID}&format=json"
body = {"deviceId"=>"reverb-test-suite"}.to_json
100.times do 
begin 
  response = RestClient.post endpoint, body, :content_type => "application/json"
rescue => e
  raise StandardError.new(e.message+" "+endpoint)
end
data = JSON.parse response
puts data['token']
end