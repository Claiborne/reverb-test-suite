require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'

%w(0 50 100 150).each do |skip|
  describe "TRENDING API -- Get 'Me' Articles For Anon User" do

    before(:all) do
      # Get bifrost environment
      ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
      @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

      # Set headers
      @headers = {:content_type => 'application/json', :accept => 'application/json'}

      # Get anon session token
      @session_token = get_anon_token(@bifrost_env) 

      # Get Articles for Anon User
      url = @bifrost_env+"/trending/tiles/me?#{skip}=0&limit=100&api_key="+@session_token
      begin
        response = RestClient.get url, @headers
      rescue => e
        raise StandardError.new(e.message+" "+url)
      end
      @data = JSON.parse response
    end

    it "should get 24 'me' articles" do
      @data['tiles'].length.should == 24
    end

    it "should only return articles of type 'article'" do
      @data['tiles'].each do |i|
        i['tileType'].should == 'article'
      end
    end

    it 'should not return any duplicates' do
      interest_values = []
      @data['tiles'].each do |i|
        interest_values << i['contentId']
      end
      interest_values.should == interest_values.uniq
    end
  end
end

%w(0 50 100 150).each do |skip|
  describe "TRENDING API -- Get 'Global' Articles For Anon User" do

    before(:all) do
      # Get bifrost environment
      ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
      @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

      # Set headers
      @headers = {:content_type => 'application/json', :accept => 'application/json'}

      # Get anon session token
      @session_token = get_anon_token(@bifrost_env) 

      # Get Articles for Anon User
      url = @bifrost_env+"/trending/tiles/global?#{skip}=0&limit=100&api_key="+@session_token
      begin
        response = RestClient.get url, @headers
      rescue => e
        raise StandardError.new(e.message+" "+url)
      end
      @data = JSON.parse response
    end

    it "should get 24 'global' articles" do
      @data['tiles'].length.should == 24
    end

    it "should only return interests of type 'article'" do
      @data['tiles'].each do |i|
        i['tileType'].should == 'article'
      end
    end

    it 'should not return any duplicates' do
      interest_values = []
      @data['tiles'].each do |i|
        interest_values << i['contentId']
      end
      interest_values.should == interest_values.uniq
    end
  end
end

describe "TRENDING API -- Get 'Me' Tiles for Logged in User", :test => true do

  before(:all) do

    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_anon_token(@bifrost_env) 

    # Get logged in session token
    @session_token_logged_in = get_token @bifrost_env, 'clay00', 'testpassword'

    # Get Interests for Logged-in User
    url = @bifrost_env+"/trending/tiles/me?skip=0&limit=24&api_key="+@session_token_logged_in
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    @data_logged_in = JSON.parse response

    # Get Interests for Anon User
    url = @bifrost_env+"/trending/tiles/me?skip=0&limit=24&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    @data_anon = JSON.parse response
  end

  it "should get 24 'me' tiles" do
    @data_logged_in['tiles'].length.should == 24  
  end

  it "should get different tiles from an anon user" do
    logged_in_tiles = []
    anon_tiles = []

    # Get logged-in tiles
    @data_logged_in['tiles'].each do |tile|
      logged_in_tiles << tile['contentId']
    end

    # Get anon tiles
    @data_anon['tiles'].each do |tile|
      anon_tiles << tile['contentId']
    end

    # Compare logged-in interests to anon interests
    logged_in_tiles.should_not == anon_tiles
  end
end
