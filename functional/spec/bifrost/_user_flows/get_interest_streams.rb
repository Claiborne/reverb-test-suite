require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'colorize'

include Token

describe "USER FLOWS - Get Interests Streams For an Anon User" do

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

  it 'should get 100 global interest values' do
    url = @bifrost_env+"/trending/interests/global?skip=0&limit=100&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    interests = (JSON.parse response)['interests']
    interests.count.should == 100
    interests.each {|i| Interests_Helper.global << i['value']}
    Interests_Helper.global.length.should == 100
  end

  it "should return 24 articles for each 'me' interest" do
    errors = []
    Interests_Helper.me.each do |interest|
      url = @bifrost_env+"/interests/stream/me?interest=#{CGI::escape interest}&skip=0&limit=50&api_key="+@session_token
      begin
        response = RestClient.get url, @headers
      rescue RestClient::ResourceNotFound => e
        errors << url
        next
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
      data = JSON.parse response
      errors << interest if data['tiles'].length != 24
    end
    errors.should == []
  end

  it "should return at least one article for each 'global' interest" do
    errors = []
    Interests_Helper.global.each do |interest|
      url = @bifrost_env+"/interests/stream/global?interest=#{CGI::escape interest}&skip=0&limit=50&api_key="+@session_token
      begin
        response = RestClient.get url, @headers
      rescue RestClient::ResourceNotFound => e
        errors << url
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
      data = JSON.parse response
      errors << interest if data['tiles'].length == 0
    end
    errors.should == []
  end
end
