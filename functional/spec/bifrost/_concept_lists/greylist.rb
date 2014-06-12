require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'colorize'

include Token

describe "CONCEPT LISTS - Grey-listed Concepts", :concept_lists => true, :test => true do
  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_anon_token(@bifrost_env)

    @grey_listed_word = 'Female'
  end

  it 'should appear as a tile when searched for' do
    grey_interest = @grey_listed_word
    url = @bifrost_env+"/interests/search/#{grey_interest}?limit=10&api_key="+@session_token
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
    search_results.include?(grey_interest).should be_true
  end

  it 'should add the grey-listed interest' do
    # two steps: an event then interest POST

    event_url = @bifrost_env+"/events/click?deviceId=reverb-test-suite&api_key=#@session_token"
    event_body = {"events"=>[{"eventArgs"=>[{"name"=>"interestName","value"=>@grey_listed_word},
    {"name"=>"wasEntered","value"=>@grey_listed_word}],"eventType"=>"uAddedInterest","location"=>{"lat"=>37.785852,"lon"=>-122.406529},
    "startTime"=>Time.now.to_i*1000}]}.to_json
    begin
      response = RestClient.post event_url, event_body, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+event_url)
    end
    sleep 1

    url = @bifrost_env+"/interests?api_key="+@session_token
    begin
      response = RestClient.post url, {:value=>@grey_listed_word,:interestType=>:interest}.to_json, @headers
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
    me_wall.include?(@grey_listed_word).should be_true
  end
end
