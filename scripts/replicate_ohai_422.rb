require 'rest_client'
require 'json'

def get_anon_token(base_url)
  endpoint = "#{base_url}/account/ohai?clientId=515b32b0e4b03f3544d60a15&format=json"
  body = {"deviceId"=>"reverb-test-suite"}.to_json
  begin 
    response = RestClient.post endpoint, body, :content_type => "application/json"
  rescue => e
    raise StandardError.new(e.message+" "+endpoint)
  end
  data = JSON.parse response
  data['token']
end

15.times do 
  get_anon_token "https://api.helloreverb.com/v2" 
  puts "."
end

