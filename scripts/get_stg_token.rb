require 'rest_client'
require 'json'

endpoint = "https://stage-api.helloreverb.com/v2/account/ohai?format=json"
body = {"deviceId"=>"reverb-test-suite"}.to_json
begin 
  response = RestClient.post endpoint, body, :content_type => "application/json"
rescue => e
  raise StandardError.new(e.message+" "+endpoint)
end
data = JSON.parse response
puts data['token']