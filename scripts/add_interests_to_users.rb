require 'rest-client'
require 'json'
require 'colorize'

@x = 0

@interests = "/Users/willclaiborne/code/reverb-test-suite/scripts/stg-interests.txt"
sessions = "/Users/willclaiborne/code/reverb-test-suite/scripts/stg-sessions.txt"

def random_interest
  chosen_line = nil
  File.foreach(@interests).each_with_index do |line, number|
    chosen_line = line if rand < 1.0/(number+1)
  end
  chosen_line.strip
end

File.open(sessions, "r").each_line do |session|
  url = "https://stage-api.helloreverb.com/v2/interests?api_key=#{session}"
  95.times do 
    RestClient.post url, {"value"=>random_interest,"interestType"=>"interest"}.to_json, :content_type => 'application/json'
  end
  puts @x
  @x = @x+1
end
