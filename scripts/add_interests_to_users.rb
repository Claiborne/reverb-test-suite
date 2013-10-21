require 'rest-client'
require 'json'
require 'colorize'

@interests = "/Users/willclaiborne/code/reverb-test-suite/scripts/prd-interests.txt"
sessions = "/Users/willclaiborne/code/reverb-test-suite/scripts/prd-sessions.txt"

def random_interest
  chosen_line = nil
  File.foreach(@interests).each_with_index do |line, number|
    chosen_line = line if rand < 1.0/(number+1)
  end
  chosen_line.strip
end

File.open(sessions, "r").each_line do |session|
  url = "https://api.helloreverb.com/v2/interests?api_key=#{session}"
  7.times do 
    RestClient.post url, {"value"=>random_interest,"interestType"=>"interest"}.to_json, :content_type => 'application/json'
  end
  puts session
end
