require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'

include Token

describe "USER FLOWS - Check Trending Tiles Are Updating" do

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    @session_token = get_anon_token @bifrost_env

    # Get anon me tiles
    url = @bifrost_env+"/trending/tiles/me?skip=0&limit=24&api_key="+@session_token
    begin
      anon_me_response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    @anon_me_tiles = JSON.parse anon_me_response

    # Get anon global tiles
    url = @bifrost_env+"/trending/tiles/global?skip=0&limit=24&api_key="+@session_token
    begin
      anon_global_response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    @anon_global_tiles = JSON.parse anon_global_response

    # Sign in
    login = get_token_and_login @bifrost_env, 'clay01', 'testpassword'
    @session_token = login[0]
    @user_id = login[1]
  end

  it 'should return first trending me article no more than 2 hours old' do
    first_article = Time.parse(@anon_me_tiles['tiles'][0]['publishDate']).to_i
    time_difference = Time.now.utc.to_i - first_article
    time_difference.should < 60*60*2
  end
  
  it 'should return first trending social article no more than 2 hours old' do

    social_token = get_social_token @bifrost_env

    url = @bifrost_env+"/trending/tiles/social?skip=0&limit=24&api_key="+social_token
    begin
      social_response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    @social_tiles = JSON.parse social_response

    first_article = Time.parse(@social_tiles['tiles'][0]['attribution'][0]['shareDate']).to_i
    time_difference = Time.now.utc.to_i - first_article
    time_difference.should < 60*60*2
  end

  it 'should return first trending global article no more than 2 hours old' do
    first_article = Time.parse(@anon_global_tiles['tiles'][0]['publishDate']).to_i
    time_difference = Time.now.utc.to_i - first_article
    time_difference.should < 60*60*2
  end
end