require 'json'
require 'rest_client'

tokens = []

File.open("/Users/wclaiborne/Documents/load_test_05_2014/prd_tokens.txt", "r").each_line do |line|
  tokens << line.strip
end

tokens.each do |session|
  sleep 0.3
  puts session
  begin
    res = RestClient.get "https://api.helloreverb.com/v2/trending/interests/me?limit=5&api_key=#{session}", {:content_type => 'application/json', :accept => 'application/json'}
  rescue
    puts 'failed'
    next
  end
  data = JSON.parse res
  concepts = []
  concepts << data['interests'][0]['value'].strip
  concepts << data['interests'][1]['value'].strip

  concepts.each do |concept|
    puts concept
    RestClient.delete "https://api.helloreverb.com/v2/interests?interest=#{CGI::escape concept}&api_key=#{session}"
  end
end
