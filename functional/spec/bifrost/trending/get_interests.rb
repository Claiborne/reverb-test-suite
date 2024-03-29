require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'api_checker.rb'; include APIChecker

describe "TRENDING - Get Me Interests For Anon User" do

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_anon_token @bifrost_env

    # Get Interests for Anon User
    url = @bifrost_env+"/trending/interests/me?skip=0&limit=100&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    @data = JSON.parse response
  end

  it "should get 24 me topics" do
    topics = []
    @data['interests'].each do |interest|
      topics << interest unless interest['value'] == 'News'
    end
    topics.length.should == 24
  end

  it "should return a non-nil, non-blank 'value' value for each tile" do
    @data['interests'].each do |interest|
      check_not_nil interest['value']
      check_not_blank interest['value']
    end
  end

    it "should return a non-nil, non-blank 'score' value for each tile" do
      @data['interests'].each do |interest|
      check_not_nil interest['score']
      check_not_blank interest['score']
    end
  end

  it "should only return interests of type 'interest' or 'collection'" do
    @data['interests'].each do |i|
      ['interest','collection'].include?(i['interestType']).should be_true
    end
  end

  it 'should not return any duplicates' do
    interest_values = []
    @data['interests'].each do |i|
      interest_values << i['value']
    end
    interest_values.should == interest_values.uniq
  end
end

describe "TRENDING - Get News Interests For Anon User" do

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_anon_token @bifrost_env

    # Get Interests for Anon User
    url = @bifrost_env+"/trending/interests/global?skip=0&limit=100&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    @data = JSON.parse response
  end

  it "should get 100 news interests" do
    @data['interests'].length.should == 100
  end

  it "should return a non-blank, non-nil 'value' value" do
    @data['interests'].each do |interest|
      check_not_nil interest['value']
      check_not_blank interest['value']
    end
  end

  it "should return a non-blank, non-nil 'score' value" do
    @data['interests'].each do |interest|
      check_not_nil interest['score']
      check_not_blank interest['score']
    end
  end

  it "should only return interests of type 'interest' or collection" do
    @data['interests'].each do |i|
      ['interest','collection'].include?(i['interestType']).should be_true
    end
  end

  it 'should not return any duplicates (FAILS IN PROD ONLY IF RVB-6540)' do
    interest_values = []
    @data['interests'].each do |i|
      interest_values << i['value']
    end
    interest_values.should == interest_values.uniq
  end
end

describe "TRENDING - Get Me Interests for Logged in User" do

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

    # Get Interests for Logged-in User
    url = @bifrost_env+"/trending/interests/me?skip=0&limit=25&api_key="+@session_token_logged_in
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    @data_logged_in = JSON.parse response

    # Get Interests for Anon User
    url = @bifrost_env+"/trending/interests/me?skip=0&limit=25&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    @data_anon = JSON.parse response
  end

  it "should get 25 me interests" do
    @data_logged_in['interests'].length.should == 25  
  end

  it "should get different interests from an anon user" do
    logged_in_interests = []
    anon_interests = []

    # Get logged-in interests
    @data_logged_in['interests'].each do |interest|
      logged_in_interests << interest['value']
    end

    # Get anon interests
    @data_anon['interests'].each do |interest|
      anon_interests << interest['value']
    end

    # Compare logged-in interests to anon interests
    logged_in_interests.should_not == anon_interests
  end
end

describe "TRENDING - Get Social Interests for Logged in Social User", :strict => true do

  before(:all) do

    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_social_token @bifrost_env

    # Get Interests for Logged-in User
    url = @bifrost_env+"/trending/interests/social?skip=0&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    @data_logged_in = JSON.parse response
  end

  it "should get 500 social interests" do
    @data_logged_in['interests'].length.should == 500  
  end
end

describe "TRENDING - Skip and Limit for Trending Interests" do

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_anon_token @bifrost_env
  end

  it "should limit 10 global interests" do
    url = @bifrost_env+"/trending/interests/global?limit=10&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response 
    data['interests'].length.should == 10
  end

  it "should limit 10 me interests" do
    url = @bifrost_env+"/trending/interests/me?limit=10&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response  
    data['interests'].length.should == 10
  end

  it "should correctly paginate global interests" do
    # get first page +1
    url = @bifrost_env+"/trending/interests/global?skip=0&limit=26&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    first_page = JSON.parse response 

    # get second page
    url = @bifrost_env+"/trending/interests/global?skip=25&limit=26&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    second_page = JSON.parse response 

    first_page['interests'].last['value'].should == second_page['interests'].first['value']
  end
  
  it "should correctly paginate me interests" do
    # get logged in session b/c anon only returns 25 interests
    user_token = get_token @bifrost_env, 'clay01', 'testpassword'

    # get first page +1
    url = @bifrost_env+"/trending/interests/me?skip=0&limit=26&api_key="+user_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    first_page = JSON.parse response 

    # get second page
    url = @bifrost_env+"/trending/interests/me?skip=25&limit=26&api_key="+user_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    second_page = JSON.parse response 

    first_page['interests'].last['value'].should == second_page['interests'].first['value']
  end
end
