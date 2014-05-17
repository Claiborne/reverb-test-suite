require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'api_checker.rb'; include APIChecker

describe "TRENDING - Ghost Users" do

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session = get_social_token @bifrost_env, 'johnthunderghost'

    url = @bifrost_env+"/trending/interests/social?skip=0&api_key="+@session
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    @social_interests = JSON.parse response

    url = @bifrost_env+"/trending/tiles/social?skip=0&api_key="+@session
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    @social_tiles = JSON.parse response
  end

  it "should display in social interests" do
    ghost_users = []
    @social_interests['interests'].each do |social_interest|
      ghost_users << social_interest if social_interest['interestType'] == 'person'
    end
    ghost_users.count.should > 0
  end

  it "should display at least 4 ghost users in all social interests" do
    ghost_users = []
    @social_interests['interests'].each do |social_interest|
      ghost_users << social_interest if social_interest['interestType'] == 'person'
    end
    ghost_users.count.should > 3
  end

  it "should display in social tiles" do
    ghost_users = []
    @social_tiles['tiles'].each do |social_tiles|
      ghost_users << social_tiles if social_tiles['tileType'] == 'person'
    end
    ghost_users.count.should > 0
  end
  it "should display at least 2 ghost users in first 24 social tiles" do
    ghost_users = []
    @social_tiles['tiles'].each do |social_tiles|
      ghost_users << social_tiles if social_tiles['tileType'] == 'person'
    end
    ghost_users.count.should > 1
  end

end
