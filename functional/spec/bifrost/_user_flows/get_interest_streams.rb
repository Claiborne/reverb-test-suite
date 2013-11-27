require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'colorize'; require 'Time'

include Token

describe "USER FLOWS - Get Trending interests For an Anon User" do

  class Interests_Helper
    @me = []; @global = []
    class << self; attr_accessor :me, :global; end
  end

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_anon_token(@bifrost_env)
  end

  it 'should get 25 (max allowed) me interest values' do
    url = @bifrost_env+"/trending/interests/me?skip=0&limit=100&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    interests = (JSON.parse response)['interests']
    interests.each {|i| Interests_Helper.me << i['value']}
    Interests_Helper.me.length.should == 25
  end

  it 'should return at least 300 global interest values' do
    url = @bifrost_env+"/trending/interests/global?skip=0&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    interests = (JSON.parse response)['interests']
    interests.each {|i| Interests_Helper.global << i['value']}
    interests.count.should > 299
    Interests_Helper.global.length.should > 299
  end

  it "should return 24 articles for each 'me' interest" do
    errors = []
    Interests_Helper.me.each do |interest|
      url = @bifrost_env+"/interests/stream/me?interest=#{CGI::escape interest}&skip=0&limit=50&api_key="+@session_token
      begin
        response = RestClient.get url, @headers
      rescue RestClient::ResourceNotFound => e
        errors << "#{url} 404 Not Found"
        next
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
      data = JSON.parse response
      errors << interest if data['tiles'].length != 24
    end
    errors.should == []
  end

  it "should return recent articles for each 'me' interest" do
    errors = []
    Interests_Helper.me.each do |interest|
      url = @bifrost_env+"/interests/stream/me?interest=#{CGI::escape interest}&skip=0&limit=50&api_key="+@session_token
      begin
        response = RestClient.get url, @headers
      rescue RestClient::ResourceNotFound => e
        errors << "#{url} 404 Not Found"
        next
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
      data = JSON.parse response

      first_article_date = data['tiles'][0]['publishDate']
      first_article_time = Time.parse first_article_date
      time_difference = Time.now.to_i - first_article_time.to_i
      puts time_difference
      errors << "#{interest}: first article more than 12 hours old" if time_difference > 60*60*12
    end
    errors.should == []
  end

  it "should return at least one recent article for each 'global' interest" do
    blank_tiles = []
    not_recent = []
    Interests_Helper.global.each do |interest|
      url = @bifrost_env+"/interests/stream/global?interest=#{CGI::escape interest}&skip=0&limit=50&api_key="+@session_token
      begin
        response = RestClient.get url, @headers
      rescue RestClient::ResourceNotFound => e
        blank_tiles << "#{url} 404 Not Found"
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
      data = JSON.parse response
      blank_tiles << interest if data['tiles'].length == 0

      # check recency
      begin 
        first_article_date = data['tiles'][0]['publishDate']
        first_article_time = Time.parse first_article_date
        time_difference = Time.now.to_i - first_article_time.to_i
        time_difference.should < 60*60*12
      rescue => e
        not_recent << "#{interest} may not be updating"
      end
    end
    blank_tiles.should == []
    not_recent.should == []
  end
end
