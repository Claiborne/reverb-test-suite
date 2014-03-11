require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'bifrost/trending_helper.rb'
require 'time'
require 'api_checker.rb'; include APIChecker

%w(0 25 50 75 100 125 150 175 200).each do |skip|
  describe "TRENDING - Get 'Me' Tiles For Anon User (skip #{skip})" do

    before(:all) do
      # Get bifrost environment
      ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
      @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

      # Set headers
      @headers = {:content_type => 'application/json', :accept => 'application/json'}

      # Get anon session token
      @session_token = get_anon_token @bifrost_env

      # Get Articles for Anon User
      url = @bifrost_env+"/trending/tiles/me?#{skip}=0&limit=24&api_key="+@session_token
      begin
        response = RestClient.get url, @headers
      rescue => e
        raise StandardError.new(e.message+" "+url)
      end
      @data = JSON.parse response
    end

    include_examples "Trending Tiles Basic Checks"

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

    it 'should sort by publish date' do
      dates = []
      @data['tiles'].each do |tile|
        dates << tile['publishDate']
      end
      dates.should == dates.sort {|x,y| y <=> x }
    end
  end
end

%w(0 25 50 75 100 125 150 175 200).each do |skip|
  describe "TRENDING - Get 'Global' Tiles For Anon User (skip #{skip})" do

    before(:all) do
      # Get bifrost environment
      ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
      @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

      # Set headers
      @headers = {:content_type => 'application/json', :accept => 'application/json'}

      # Get anon session token
      @session_token = get_anon_token @bifrost_env

      # Get Articles for Anon User
      url = @bifrost_env+"/trending/tiles/global?#{skip}=0&limit=24&api_key="+@session_token
      begin
        response = RestClient.get url, @headers
      rescue => e
        raise StandardError.new(e.message+" "+url)
      end
      @data = JSON.parse response
    end

    include_examples "Trending Tiles Basic Checks"

    it "should get 24 'global' articles" do
      @data['tiles'].length.should == 24
    end

    it "should only return tiles of type 'article'" do
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

    it 'should sort by publish date' do
      dates = []
      @data['tiles'].each do |tile|
        dates << tile['publishDate']
      end
      dates.should == dates.sort {|x,y| y <=> x }
    end  
  end
end

describe "TRENDING - Get 'Me' Tiles for Logged in User" do

  before(:all) do

    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_anon_token @bifrost_env

    # Get logged in session token
    @session_token_logged_in = get_token @bifrost_env, 'clay01', 'testpassword'

    # Get tiles for logged-in user
    url = @bifrost_env+"/trending/tiles/me?skip=0&limit=24&api_key="+@session_token_logged_in
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    @data_logged_in = JSON.parse response
    @data = @data_logged_in

    # Get tiles for anon user
    url = @bifrost_env+"/trending/tiles/me?skip=0&limit=24&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    @data_anon = JSON.parse response
  end

  include_examples "Trending Tiles Basic Checks"

  it 'should return a count.items value of > 1 for each interest tile' do
    interests = []
    @data['tiles'].each do |tile|
      if tile['tileType'] == 'interest'
        interests << tile['contentId']
        tile['count']['items'].should > 1
      end
    end 
    interests.count.should > 0
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

describe "TRENDING - Get 'Social' Tiles for Logged in User" do

  before(:all) do

    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get social session token
    @session_token = get_social_token @bifrost_env

    # Get tiles for logged-in user
    url = @bifrost_env+"/trending/tiles/social?skip=0&limit=24&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    @data_logged_in = JSON.parse response
    @data = @data_logged_in
  end

  include_examples "Trending Tiles Basic Checks"

  it "should get 24 'social' tiles" do
    @data_logged_in['tiles'].length.should == 24  
  end

  it "should return an attribution key for each tile" do
    @data_logged_in['tiles'].each do |tile|
      tile['attribution'].should be_true
    end
  end

  %w(network shareDate remoteHandle remoteId).each do |key|
    it "should return a non-blank, non-nil 'attribution.#{key}' value for each tile" do
      @data_logged_in['tiles'].each do |tile|
        unless tile['tileType'] == 'person'
          tile['attribution'][0][key].should be_true
          check_not_blank tile['attribution'][0][key]
          check_not_nil tile['attribution'][0][key]
        end
      end
    end
  end
end

describe "TRENDING - Skip and Limit for Trending Tiles" do
  
  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon and social tokens
    @session_token = get_anon_token @bifrost_env
    @social_session_token = get_social_token @bifrost_env
  end

  it "should limit 10 global tiles" do
    url = @bifrost_env+"/trending/tiles/global?limit=10&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response 
    data['tiles'].length.should == 10
  end

  it "should limit 10 me tiles" do
    url = @bifrost_env+"/trending/tiles/me?limit=10&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response  
    data['tiles'].length.should == 10
  end

  it "should limit 10 social tiles" do
    url = @bifrost_env+"/trending/tiles/social?limit=10&api_key="+@social_session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response  
    data['tiles'].length.should == 10
  end

  it "should correctly paginate global tiles" do
    # get first page
    url = @bifrost_env+"/trending/tiles/global?skip=0&limit=24&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    first_page = JSON.parse response 

    url = @bifrost_env+"/trending/tiles/global?skip=#{first_page['tiles'].count-1}&limit=24&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    second_page = JSON.parse response 

    first_page['tiles'].last['contentId'].should == second_page['tiles'].first['contentId']
  end
  
  it "should correctly paginate me tiles" do
    # get first page
    url = @bifrost_env+"/trending/tiles/me?skip=0&limit=24&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    first_page = JSON.parse response 

    # get second page
    url = @bifrost_env+"/trending/tiles/me?skip=#{first_page['tiles'].count-1}&limit=24&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    second_page = JSON.parse response 

    first_page['tiles'].last['contentId'].should == second_page['tiles'].first['contentId']
  end

  xit "should correctly paginate social tiles (FAILS IN PRODUCTION)" do
    # get first page
    url = @bifrost_env+"/trending/tiles/social?skip=0&limit=24&api_key="+@social_session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    first_page = JSON.parse response 

    # get second page
    url = @bifrost_env+"/trending/tiles/social?skip=#{first_page['tiles'].count-1}&limit=24&api_key="+@social_session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    second_page = JSON.parse response 

    first_page['tiles'].last['contentId'].should == second_page['tiles'].first['contentId']
  end

  it "should paginate global tiles past 450" do
    url = @bifrost_env+"/trending/tiles/global?skip=450&limit=24&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    data['tiles'].length.should > 0
  end

  it "should paginate me tiles past 200" do
    url = @bifrost_env+"/trending/tiles/me?skip=200&limit=24&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    data['tiles'].length.should > 0
  end

  it "should paginate social tiles past 200" do
    url = @bifrost_env+"/trending/tiles/social?skip=200&limit=24&api_key="+@social_session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    data['tiles'].length.should > 0
  end
end
