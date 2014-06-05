require 'json'
require 'rest_client'

tokens = []

File.open("/Users/wclaiborne/code/reverb-performance-suite/load_test_05_2014/stg_tokens.txt", "r").each_line do |line|
  tokens << line.strip
end

tokens.each do |session|
  #puts session
  begin
    res = RestClient.get "https://stage-api.helloreverb.com/v2/userProfile/mine?api_key=#{session}", {:content_type => 'application/json', :accept => 'application/json'}
  rescue
    puts "#{session} failed"
    next
  end
  data = JSON.parse res
  puts data['userId']
end