require 'rest-client'
require 'json'


env = "https://stage-api.helloreverb.com/v2"
endpoint = "/account/register?clientId=515b32b0e4b03f3544d60a15&format=json"
name = 'clay1test'

(23001..24000).each do |n|
  body = {
    "login"=>"#{name}#{n}",
    "password"=>"testpassword",
    "passwordConfirmation"=>"testpassword",
    "email"=>"#{name}#{n}@faketestuser.com",
    "name"=>"#{name}#{n}",
    "deviceId"=>"reverb-test-suite"
  }.to_json
  begin
    r = RestClient.post env+endpoint, body, :content_type => 'application/json', :accpet => :json
  rescue
    next
  end
  d = JSON.parse r
  puts d['userId']
end
  
