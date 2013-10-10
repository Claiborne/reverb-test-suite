require 'rest_client'
require 'json'

CLIENTID = '515b32b0e4b03f3544d60a15'
endpoint = "https://stage-api.helloreverb.com/v2/account/ohai?clientId=#{CLIENTID}&format=json"
body = {"deviceId"=>"reverb-test-suite"}.to_json
begin 
  response = RestClient.post endpoint, body, :content_type => "application/json"
rescue => e
  raise StandardError.new(e.message+" "+endpoint)
end
data = JSON.parse response
puts data['token']