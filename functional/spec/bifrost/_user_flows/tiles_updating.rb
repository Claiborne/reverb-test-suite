require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'

include Token

describe "USER FLOWS - Check Trending Tiles Are Updating", :tiles_updating => true do
  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    @session_token = get_anon_token @bifrost_env
    @signed_in_session_token = get_token @bifrost_env, 'clay01', 'testpassword'

    # Get anon me tiles
    url = @bifrost_env+"/trending/tiles/me?skip=0&limit=24&api_key="+@session_token
    begin
      anon_me_response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    @anon_me_tiles = JSON.parse anon_me_response

    # Get signed-in me tiles
    url = @bifrost_env+"/trending/tiles/me?skip=0&limit=24&api_key="+@signed_in_session_token
    begin
      signed_in_me_response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    @signed_in_me_tiles = JSON.parse signed_in_me_response

    # Get anon global tiles
    url = @bifrost_env+"/trending/tiles/global?skip=0&limit=24&api_key="+@session_token
    begin
      anon_global_response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    @anon_global_tiles = JSON.parse anon_global_response

    # Get signed-in global tiles
    url = @bifrost_env+"/trending/tiles/global?skip=0&limit=24&api_key="+@signed_in_session_token
    begin
      signed_in_global_response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    @signed_in_global_tiles = JSON.parse signed_in_global_response

    # Sign in
    login = get_token_and_login @bifrost_env, 'clay01', 'testpassword'
    @session_token = login[0]
    @user_id = login[1]
  end

  it 'should return first trending me article no more than 2 hours old for anon user', :strict => true do
    first_article = Time.parse(@anon_me_tiles['tiles'][0]['publishDate']).to_i
    time_difference = Time.now.utc.to_i - first_article
    time_difference.should < 60*60*2
  end

  it 'should return first trending me article no more than 8 hours old for anon user' do
    first_article = Time.parse(@anon_me_tiles['tiles'][0]['publishDate']).to_i
    time_difference = Time.now.utc.to_i - first_article
    time_difference.should < 60*60*8
  end

  it 'should return a trending me article, in the first page, no more than 2 hours old for signed-in user', :strict => true do
    article_pub_dates = []
    @signed_in_me_tiles['tiles'].each do |t|
      article_pub_dates << Time.parse(t['publishDate']).to_i if t['publishDate']
    end
    article_pub_dates.length.should > 10

    time_differences = []

    article_pub_dates.each do |date|
      time_differences << Time.now.utc.to_i - date
    end
    time_differences.sort.first.should < 60*60*2
  end

  it 'should return a trending me article, in the first page, no more than 8 hours old for signed-in user' do
    article_pub_dates = []
    @signed_in_me_tiles['tiles'].each do |t|
      article_pub_dates << Time.parse(t['publishDate']).to_i if t['publishDate']
    end
    article_pub_dates.length.should > 10

    time_differences = []

    article_pub_dates.each do |date|
      time_differences << Time.now.utc.to_i - date
    end
    time_differences.sort.first.should < 60*60*8
  end
  
  it 'should return first trending social article no more than 30 minutes old', :strict => true do
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
    time_difference.should < 60*30
  end

  it 'should return first trending global article no more than 2 hours old for anon user' do
    first_article = Time.parse(@anon_global_tiles['tiles'][0]['publishDate']).to_i
    time_difference = Time.now.utc.to_i - first_article
    time_difference.should < 60*60*2
  end

  it 'should return first trending global article no more than 2 hours old for signed-in user' do
    first_article = Time.parse(@signed_in_global_tiles['tiles'][0]['publishDate']).to_i
    time_difference = Time.now.utc.to_i - first_article
    time_difference.should < 60*60*2
  end
end