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

  def get_token(base_url, login, password)
    login_endpoint = "#{base_url}/account/login"
    body = {
      "login": login,
      "deviceId": "reverb-test-suite",
      "allowMergeIntoExisting": true,
      "password": password,
      "remember": true
      }.to_json
    headers = {:content_type => 'application/json', :accept => 'application/json'}
    response = RestClient.post login_endpoint, body, headers
    data = JSON.parse response
    data['token']
  end
end