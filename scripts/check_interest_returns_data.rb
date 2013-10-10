require 'rest-client'
require 'json'
require 'colorize'

path = "/Users/willclaiborne/code/reverb-test-suite/performance/thunderstone_092013/stg-interests.txt"

interests = []
failures = []

File.open(path, "r").each_line do |line|
  interests << line.strip
end

session = '39d3afdf7601ead7a223f22ecd8d4ae59d2526589c787fd8'

interests.each do |interest|
  begin
    res = RestClient.get "https://stage-api.helloreverb.com/v2/interests/stream?interest=#{CGI::escape interest}&skip=0&limit=1&api_key=#{session}&format=json"
    #puts "https://stage-api.helloreverb.com/v2/interests/stream?interest=#{CGI::escape interest}&skip=0&limit=1&api_key=#{session}&format=json"
    data = JSON.parse res
    if data['tiles'].length == 0
      failures << interest
      puts "#{interest}".red
    else
    end
  rescue => e
    puts "#{interest} failed #{e.message}".
    next
  end
end

puts "#{failures}".yellow