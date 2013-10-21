require 'rest-client'
require 'json'

env = "https://dev-api.helloreverb.com/v2"
endpoint = "/account/register?clientId=51561484e4b0edfcfec11627"

(0..2500).each do |n|
  body = {
    "login"=>"clayt3#{n}",
    "password"=>"testpassword",
    "passwordConfirmation"=>"testpassword",
    "email"=>"claytest3#{n}@faketestuser.com",
    "name"=>"clayt3#{n}",
    "deviceId"=>"reverb-test-suite"
  }.to_json

  RestClient.post env+endpoint, body, :content_type => 'application/json'
  puts n

end
