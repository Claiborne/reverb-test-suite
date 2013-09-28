require 'rest-client'
require 'json'

env = "https://stage-api.helloreverb.com/v2"
endpoint = "/account/login"

list_of_sessions = []

(0..99).each do |n|
  body = {
    "login"=>"clayt3#{n}",
    "password"=>"testpassword",
    "passwordConfirmation"=>"testpassword",
    "email"=>"claytest3#{n}@faketestuser.com",
    "name"=>"clayt3#{n}",
    "deviceId"=>"reverb-test-suite"
  }.to_json

  RestClient.post env+endpoint, body, :content_type => 'application/json'
end

File.open('/Users/willclaiborne/code/reverb-test-suite/scripts/stage-sessions.txt', 'w')  do |file|
  list_of_sessions.each do |s|
    file.write s
  end
end