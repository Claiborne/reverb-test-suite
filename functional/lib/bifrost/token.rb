require 'rest_client'
require 'json'

module Token

  def get_client_id
    if ENV['env'].downcase == 'dev'
      return '51561484e4b0edfcfec11627'
    elsif ENV['env'].downcase == 'stg'
      return '515b32b0e4b03f3544d60a15'
    elsif ENV['env'].downcase == 'prd'
      return '515b32b0e4b03f3544d60a15'
    else
      raise StandardError, "Unable to return a clientId value from lib/bifrost/token.rb"
    end
  end

  def get_anon_token(base_url)
    endpoint = "#{base_url}/account/ohai?clientId=#{get_client_id}&format=json"
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
    login_endpoint = "#{base_url}/account/login?clientId=#{get_client_id}"
    body = {
      "login" => login,
      "deviceId" => "reverb-test-suite",
      "allowMergeIntoExisting" => true,
      "password" => password,
      "remember" => true
      }.to_json
    headers = {:content_type => 'application/json', :accept => 'application/json'}
    begin
      response = RestClient.post login_endpoint, body, headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse response
    data['token']
  end
end