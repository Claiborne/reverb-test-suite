require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'colorize'

include Token

describe "USER FLOWS - Add and Remove Interest to Anon User", :test => true do

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_anon_token(@bifrost_env)

    # Interest to Add
    @interest = 'Cake'
  end

  it 'should add an interest' do
    # add interest
    url = @bifrost_env+"/interests?api_key="+@session_token
    begin
      response = RestClient.post url, {:value=>@interest,:interestType=>:interest}.to_json, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
  end

  it 'should display the interest in me wordwall' do
    # check interest added to me wall
    url = @bifrost_env+"/trending/interests/me?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse response
    me_wall = []
    data['interests'].each do |interest|
      me_wall << interest['value']
    end
    me_wall.include?(@interest).should be_true
  end

  it 'should display the interest in me tiles' do
    me_tiles = []
    url = @bifrost_env+"/trending/tiles/me?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse response
    data['tiles'].each do |tile|
      me_tiles << tile['contentId']
    end
    me_tiles.include?(@interest).should be_true
  end

  it 'should remove interest' do
    url = @bifrost_env+"/interests/?interest=#@interest&api_key="+@session_token
    begin
      response = RestClient.delete url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
  end

  it 'should not display the interest in me wordwall' do
    # check interest added to me wall
    url = @bifrost_env+"/trending/interests/me?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse response
    me_wall = []
    data['interests'].each do |interest|
      me_wall << interest['value']
    end
    me_wall.include?(@interest).should_not be_true
  end
end
