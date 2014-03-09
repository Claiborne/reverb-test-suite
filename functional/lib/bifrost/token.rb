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

  def get_social_token(base_url)
    client_id = get_client_id
    endpoint = "#{base_url}/account/oauthLogin?clientId=#{client_id}"
    if ENV['env'] == 'prd'
      token = '2255573574-Xr7leYq5atAmXH9vG2Zi7dHKWzuHDJcDg4xosG1'
      secret = 'nRR4j8rsjpPJFJupk7FaXVVzuXBtl8XS5qySzy7INRyNo'
    elsif ENV['env'] == 'stg' 
      token = '2255573574-R2jWpp2ntGa4EnQ9C47QsIWKo3dAwwivXeGYMTX'
      secret = 'pHEQ4NNNGyph4U64T9KYOD88lvYQqRZy6SQm07j0HhggC'
    elsif ENV['env'] == 'dev' 
      token = '2255573574-5B1QGZ3esomOOylG6h5tcEdqb0W5bs9XY8SBlu3'
      secret = 'ogykkiUJ98CzpM1Kd70VhEclQhzG34xKHlFQlfgWNujGw'
    end              

    body = {
      "deviceId"=>"reverb-test-suite",
      "allowMergeIntoExisting"=>true,
      "userToken"=>token,
      "userSecret"=>secret,
      "provider"=>"twitter"
    }.to_json

    begin 
      response = RestClient.post endpoint, body, {:content_type => 'application/json', :accept => 'application/json'}
    rescue => e
      raise StandardError.new(e.message+" "+endpoint)
    end

    data = JSON.parse response
    token = data['userInfo']['token'] if data['userInfo']
    token = data['authSession']['token'] if data['authSession']
    token
  end

  def get_token(base_url, login, password)
    data = sign_in base_url, login, password
    data['token']
  end

  def get_token_and_login(base_url, login, password)
    data = sign_in base_url, login, password
    [data['token'], data['userId']]
  end

  private

    def sign_in(base_url, login, password)
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
        raise StandardError.new(e.message+":\n"+login_endpoint)
      end
      JSON.parse response 
    end
end
