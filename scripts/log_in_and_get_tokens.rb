require 'rest-client'
require 'json'

env = "https://stage-api.helloreverb.com/v2"
endpoint = "/account/login"
id = '515b32b0e4b03f3544d60a15'

list_of_sessions = []

(0..89).each do |n|
  body = {
  "login" => "loadtest01#{n}",
  "deviceId" => "reverb-test-suite",
  "allowMergeIntoExisting" => true,
  "password" => "testpassword",
  "remember" => false
  }.to_json

  begin
    res = RestClient.post env+endpoint+"?clientId="+id, body, :content_type => 'application/json', :accept => 'json'
  rescue
    puts "#{n} failed"
    next
  end
  data = JSON.parse res
  puts data['token']
  list_of_sessions << data['token']
end

=begin
File.open('/Users/willclaiborne/code/reverb-test-suite/scripts/stage-sessions.txt', 'w')  do |file|
  list_of_sessions.each do |s|
    file.write s+"\n"
  end
end
=end
