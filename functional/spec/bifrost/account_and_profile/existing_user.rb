require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'colorize'

include Token

describe "USER PROFILE API - Existing User"  do
  
  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Sign in
    login = get_token_and_login @bifrost_env, 'clay02', 'testpassword'
    @session_token = login[0]
    @user_id = login[1]

    profile_url = @bifrost_env+"/userProfile/byUserId/#@user_id?api_key="+@session_token
    begin
      res = RestClient.get profile_url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+profile_url)
    end
    @user_profile = JSON.parse res

  end

  it "should one favorited interest and one article" do
    article = Fav_Article_Helper.article
    url = @bifrost_env+"/userProfile/reverbs/#@user_id?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse response
    data['tiles'].length.should == 2

    favs = []
    data['tiles'].each do |favorite_tile|
      favs << favorite_tile['tileType']
    end
    favs.include?('article').should be_true
    favs.include?('interest').should be_true
  end

  it "should return the user's login name" do
    @user_profile['login'].should == 'clay02'
  end

  it "should return the user's e-mail" do
    @user_profile['email'].should == 'clay02@reverbtest.com'
  end

  it "should return a non-nil, non-blank userId value" do
    @user_profile['userId'].should_not be_nil
    @user_profile['userId'].to_s.length.should > 0
  end

  it "should return the user's bio" do
    @user_profile['bio'].should == 'Used in test automation'
  end

  it "should return the user's reverbedItems as '2'" do
    @user_profile['stats']['reverbedItems'].should == 2
  end

  it "should return a profile pic for the user" do
    RestClient.get @user_profile['profilePicture']['url']
  end

  it "should return two tile in the user's stream" do
    @user_profile['stream']['tiles'].length.should == 2
  end

  it "should return a contentId value for each tile in the user's stream" do
    @user_profile['stream']['tiles'].each do |stream_tile|
      stream_tile['contentId'].length.should > 0
      stream_tile['contentId'].should_not be_nil
    end
  end

  it "should return a concept of 'Metal Gear Solid" do
    @user_profile['concepts'][0]['value'].should == 'Metal Gear Solid'
  end

  it "should return a tileType value for each tile in the user's stream" do
    @user_profile['stream']['tiles'].each do |stream_tile|
      stream_tile['tileType'].length.should > 0
      stream_tile['tileType'].should_not be_nil
    end
  end

end