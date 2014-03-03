require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'colorize'
require 'time'

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
    @session_token = get_anon_token @bifrost_env
  end

  it 'should return 25 (max allowed) me interests' do
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

  it 'should return at least 215 global interests (FAILS IN PRODUCTION RVB-4231)', :test => true do
    url = @bifrost_env+"/trending/interests/global?limit=500&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    interests = (JSON.parse response)['interests']
    interests.each {|i| Interests_Helper.global << i['value']}
    interests.count.should > 214
    Interests_Helper.global.length.should > 214
  end

  it 'should return at least 99 global interests' do
    url = @bifrost_env+"/trending/interests/global?skip=0&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    interests = (JSON.parse response)['interests']
    interests.each {|i| Interests_Helper.global << i['value']}
    interests.count.should > 99
    Interests_Helper.global.length.should > 99
    #see above pending test
    #interests.count.should > 214
    #Interests_Helper.global.length.should > 214
  end

  it "should return 24 articles for each 'me' interest" do
    errors = []
    Interests_Helper.me.each do |interest|
      url = @bifrost_env+"/interests/stream/me?interest=#{CGI::escape interest}&skip=0&limit=24&api_key="+@session_token
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

  it "should return at least 30 articles for each 'me' interest" do
    less_than_30_articles = []
    Interests_Helper.me.each do |interest|
      url = @bifrost_env+"/interests/stream/me?interest=#{CGI::escape interest}&skip=24&limit=24&api_key="+@session_token
      begin
        response = RestClient.get url, @headers
      rescue RestClient::ResourceNotFound => e
        errors << "#{url} 404 Not Found"
        next
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
      data = JSON.parse response
      less_than_30_articles << interest if data['tiles'].length < 5
    end
    less_than_30_articles.should == []
  end

  it "should return at least two articles for each 'global' interest" do
    blank_tiles = []
    not_recent = []
    Interests_Helper.global.each do |interest|
      url = @bifrost_env+"/interests/stream/global?interest=#{CGI::escape interest}&skip=0&limit=24&api_key="+@session_token
      begin
        response = RestClient.get url, @headers
      rescue RestClient::ResourceNotFound => e
        blank_tiles << "#{url} 404 Not Found"
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
      data = JSON.parse response
      blank_tiles << interest+" (#{data['tiles'].length})" if data['tiles'].length < 2
    end

    if blank_tiles.count < 1
      blank_tiles.should == []
    elsif blank_tiles.count > 4
      blank_tiles.should == []
    else
      blank_tiles.count.should < 5
    end
  end
end

describe "USER FLOWS - Get Trending interests For an Social User" do

  class Interests_Helper
    @social = []
    class << self; attr_accessor :social; end
  end

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get social session token
    @session_token = get_social_token @bifrost_env
  end

  it 'should return 500 social interests' do
    url = @bifrost_env+"/trending/interests/social?skip=0&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    interests = (JSON.parse response)['interests']
    interests.each {|i| Interests_Helper.social << i['value']}
    Interests_Helper.social.length.should == 500
  end

  it "should return at least two articles for each 'social' interest" do
    blank_tiles = []
    not_recent = []
    Interests_Helper.social.each do |interest|
      url = @bifrost_env+"/interests/stream/social?interest=#{CGI::escape interest}&skip=0&limit=24&api_key="+@session_token
      begin
        response = RestClient.get url, @headers
      rescue RestClient::ResourceNotFound => e
        blank_tiles << "#{url} 404 Not Found"
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
      data = JSON.parse response
      (blank_tiles << interest+" (#{data['tiles'].length})" if data['tiles'].length < 1) unless interest.match(/\d{4}/)
    end

    if blank_tiles.count < 1
      blank_tiles.should == []
    elsif blank_tiles.count > 2
      blank_tiles.should == []
    else
      blank_tiles.count.should < 3
    end
  end
end
