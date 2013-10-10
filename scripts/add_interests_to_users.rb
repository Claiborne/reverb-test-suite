require 'rest-client'
require 'json'
require 'colorize'

@interests = "/Users/willclaiborne/code/reverb-test-suite/performance/thunderstone_092013/stg-interests.txt"
sessions = "/Users/willclaiborne/code/reverb-test-suite/scripts/stage-sessions.txt"

def random_interest
  chosen_line = nil
  File.foreach(@interests).each_with_index do |line, number|
    chosen_line = line if rand < 1.0/(number+1)
  end
  chosen_line.strip
end

File.open(sessions, "r").each_line do |session|
  url = "https://stage-api.helloreverb.com:443/v2/interests?api_key=#{session}"
  3.times do 
    RestClient.post url, {"value"=>random_interest,"interestType"=>"interest"}.to_json, :content_type => 'application/json'
  end
  puts session
end