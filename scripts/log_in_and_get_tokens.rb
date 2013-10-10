require 'rest-client'
require 'json'

env = "https://stage-api.helloreverb.com/v2"
endpoint = "/account/login"

list_of_sessions = []

(0..2500).each do |n|
  body = {
  "login" => "clayt3#{n}",
  "deviceId" => "reverb-test-suite",
  "allowMergeIntoExisting" => true,
  "password" => "testpassword",
  "remember" => false
  }.to_json

  begin
    res = RestClient.post env+endpoint, body, :content_type => 'application/json', :accept => 'json'
  rescue
    puts "#{n} failed"
    next
  end
  data = JSON.parse res
  list_of_sessions << data['token']
end

File.open('/Users/willclaiborne/code/reverb-test-suite/scripts/stage-sessions.txt', 'w')  do |file|
  list_of_sessions.each do |s|
    file.write s+"\n"
  end
end