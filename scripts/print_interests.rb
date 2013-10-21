require 'rest-client'
require 'json'


res = RestClient.get "https://stage-api.helloreverb.com/v2/trending/interests/global?limit=300&api_key=ce4adfb352ddac2d7f6724f224824dcd8ff6a64d77400133&format=json"
data = JSON.parse res
data['interests'].each do |interest|
  puts interest['value']
end