require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'colorize'

include Token

describe "USER FLOWS - Add and Remove Interest to Anon User", :add_remove_interests => true do

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

  it 'should search for an interest' do
    url = @bifrost_env+"/interests/search/#@interest?limit=10&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse response
    search_results = []
    data['results'].each do |result|
      search_results << result['value']
    end
    search_results.length.should > 0
    search_results.include?(@interest).should be_true
  end

  it 'should add an interest' do
    # two steps: an event then interest POST

    event_url = @bifrost_env+"/events/click?deviceId=reverb-test-suite&api_key=#@session_token"
    event_body = {"events"=>[{"eventArgs"=>[{"name"=>"interestName","value"=>@interest},
    {"name"=>"wasEntered","value"=>@interest}],"eventType"=>"uAddedInterest","location"=>{"lat"=>37.785852,"lon"=>-122.406529},
    "startTime"=>Time.now.to_i*1000}]}.to_json
    begin
      response = RestClient.post event_url, event_body, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+event_url)
    end
    sleep 1

    url = @bifrost_env+"/interests?api_key="+@session_token
    begin
      response = RestClient.post url, {:value=>@interest,:interestType=>:interest}.to_json, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    sleep 1
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

  it 'should not display the interest in me wordwall (FAILS INTERMITTENTLY IN PROD: RVB-5294)' do
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
