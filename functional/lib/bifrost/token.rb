require 'rest_client'
require 'json'

module Token

  def get_anon_token(base_url)
    endpoint = "#{base_url}/account/ohai?format=json"
    body = {"deviceId"=>"reverb-test-suite"}.to_json
    begin 
      response = RestClient.post endpoint, body, :content_type => "application/json"
    rescue => e
      raise StandardError.new(e.message+" "+endpoint)
    end
    data = JSON.parse response
    data['token']
  end
end