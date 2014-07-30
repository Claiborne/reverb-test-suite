require 'rest-client'
require 'json'
require 'colorize'

if ARGV[0] == 'prd'
  key = '72b8bd6a95a93fe871934d93e1b442e4ba95396b151a05f2' 
  domain = 'api.helloreverb.com'
end

if ARGV[0] == 'stg'
  key = 'ce4adfb352ddac2d7f6724f224824dcd8ff6a64d77400133'
  domain = 'stage-api.helloreverb.com'
end

res = RestClient.get "https://#{domain}/v2/trending/interests/global?limit=15&api_key=#{key}&format=json"
data = JSON.parse res
data['interests'].each do |interest|
  puts "#{interest['value']}".green
end