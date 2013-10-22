require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'

describe "TRENDING API -- Get 'Me' Interests For Anon User" do

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_anon_token(@bifrost_env)	

    # Get Interests for Anon User
    url = @bifrost_env+"/trending/interests/me?skip=0&limit=100&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    @data = JSON.parse response
  end

  it "should get 24 'me' interests" do
    @data['interests'].length.should == 25
  end

  it "should only return interests of type 'interest'" do
    @data['interests'].each do |i|
      i['interestType'].should == 'interest'
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

describe "TRENDING API -- Get 'Global' Interests For Anon User" do

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_anon_token(@bifrost_env) 

    # Get Interests for Anon User
    url = @bifrost_env+"/trending/interests/global?skip=0&limit=100&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    @data = JSON.parse response
  end

  it "should get 100 'global' interests" do
    @data['interests'].length.should == 100
  end

  it "should only return interests of type 'interest'" do
    @data['interests'].each do |i|
      i['interestType'].should == 'interest'
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

describe "TRENDING API -- Get 'Me' Interests for Logged in User" do

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

  it "should get 25 'me' interests" do
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
