require 'rest-client'
require 'json'

@skip = 0
@limit = 100

10.times do
  res = RestClient.get "https://dev-api.helloreverb.com/v2/interests/stream/me?interest=Obi-Wan%20Kenobi&skip=#{@skip}&limit=#{@limit}&api_key=1e905518b5ef5b47e65f01f730e741edaf6db1a519413986&format=json"
  data = JSON.parse res
  @skip = @skip + data['tiles'].count
  data['tiles'].each do |d|
    puts "#{d['header']['value']}  --  #{d['contentId']}" if d['header']
  end
end
