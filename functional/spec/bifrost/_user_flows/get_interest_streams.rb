require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'colorize'

include Token

describe "USER FLOW - Get Interests Streams" do

  class Interests
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

  it 'should get 24 me interest values' do
    url = @bifrost_env+"/trending/interests/me?skip=0&limit=100&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    interests = (JSON.parse response)['interests']
    interests.each {|i| Interests.me << i['value']}
    Interests.me.length.should == 24
  end

  it 'should get 100 global interest values' do
    url = @bifrost_env+"/trending/interests/global?skip=0&limit=100&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    interests = (JSON.parse response)['interests']
    interests.each {|i| Interests.global << i['value']}
    Interests.global.length.should == 100
  end

  it "should return data for each 'me' interest" do
    errors = []
    Interests.me.each do |interest|
      url = @bifrost_env+"/interests/stream?interest=#{CGI::escape interest}&skip=0&limit=50&api_key="+@session_token
      begin
        response = RestClient.get url, @headers
      rescue RestClient::ResourceNotFound => e
        errors << url
        next
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
      data = JSON.parse response
      data['tiles'].length.should > 0
    end
    errors.should == []
  end

  it "should return data for each 'global' interest" do
    errors = []
    Interests.global.each do |interest|
      url = @bifrost_env+"/interests/stream?interest=#{CGI::escape interest}&skip=0&limit=50&api_key="+@session_token
      begin
        response = RestClient.get url, @headers
      rescue RestClient::ResourceNotFound => e
        errors << url
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
      data = JSON.parse response
      data['tiles'].length.should > 0
    end
    errors.should == []
  end
end
