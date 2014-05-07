require 'rest-client'
require 'json'
require 'colorize'

tokens = []
concepts = []

File.open("/Users/wclaiborne/Documents/load_test_05_2014/prd_tokens.txt", "r").each_line do |line|
  tokens << line.strip
end

tokens = ['631ff33d45c7b1ee813e2e1d9b404d6e913d9bb5665792d7']

File.open("/Users/wclaiborne/Documents/load_test_05_2014/5k_stage_concepts.txt", "r").each_line do |line|
  concepts << line.strip
end

tokens.each do |session|
sleep 0.2
puts session
20.times do 

  url = "https://stage-api.helloreverb.com/v2/interests?api_key=#{session}"
  concept = concepts[rand(concepts.length)]
  puts concept

  begin 
    RestClient.post url, {"value"=>concept,"interestType"=>"interest"}.to_json, :content_type => 'application/json'
  rescue => e
    puts 'failed'
    next
  end
end; end

