require 'rest-client'
require 'json'

path = "/Users/willclaiborne/code/reverb-test-suite/performance/thunderstone_092013/interests.txt"

interests = []

File.open(path, "r").each_line do |line|
  interests << line
end

session = '39d3afdf7601ead7a223f22ecd8d4ae59d2526589c787fd8'

interests.each do |interest|
  res = RestClient.get "https://stage-api.helloreverb.com/v2/interests/stream?interest=#{CGI::escape interest}&skip=0&limit=1&api_key=#{session}&format=json"
  data = JSON.parse res
  puts data
  if data['tiles'].length == 0
    puts interest
  else
    p '.'
  end
end
