require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'

describe "Trending API -- Smoke", :smoke => true do

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_anon_token(@bifrost_env)	
  end

  it 'should get me interests for an anon session' do
    interest_type = @bifrost_env+"/trending/interests/me?skip=0&limit=100&api_key="+@session_token
    begin
      response = RestClient.get interest_type, @headers
    rescue => e
      raise StandardError.new(e.message+" "+interest_type)
    end
    data = JSON.parse response
    data['interests'].length.should > 0
  end

  it 'should get global interests for an anon session' do
    interest_type = @bifrost_env+"/trending/interests/global?skip=0&limit=100&api_key="+@session_token
    begin
      response = RestClient.get interest_type, @headers
    rescue => e
      raise StandardError.new(e.message+" "+interest_type)
    end
    data = JSON.parse response
    data['interests'].length.should > 0
  end
end
