require 'colorize'
require 'json'
require 'rest_client'
require './../functional/lib/bifrost/token.rb'; include Token

# register clay01 / testpassword 
puts "What domain? e.g., basil-api.helloreverb.com".green
domain = gets.strip

puts "Registering 'clay01 / testpassword ...".green

headers = {:content_type => 'application/json', :accept => 'application/json'}
client_id = get_client_id
url = "https://#{domain}/v2/account/register?clientId=#{client_id}"
body = {
  'login' => 'clay01',
  'password' => 'testpassword',
  'passwordConfirmation' => 'testpassword',
  'email' => 'ipadqathunder+clay01@gmail.com',
  'name' => 'clay01',
  'deviceId' => 'reverb-test-suite'
  }.to_json

begin
  RestClient.post url, body, headers
rescue => e
  raise StandardError.new(e.message+":\n"+url)
end
