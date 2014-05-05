require 'rest-client'
require 'json'

env = "https://stage-api.helloreverb.com/v2"
endpoint = "/account/register?clientId=515b32b0e4b03f3544d60a15&format=json"
name = 'loadtest01'

(0..90).each do |n|
  body = {
    "login"=>"#{name}#{n}",
    "password"=>"testpassword",
    "passwordConfirmation"=>"testpassword",
    "email"=>"ipadqathunder+#{name}#{n}@gmail.com",
    "name"=>"#{name}#{n}",
    "deviceId"=>"reverb-test-suite"
  }.to_json
  begin
    r = RestClient.post env+endpoint, body, :content_type => 'application/json', :accpet => :json
  rescue
    puts "#{n} failed" 
    next
  end
  d = JSON.parse r
  puts d['userId']
end
