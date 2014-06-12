require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'colorize'

include Token

describe "CONCEPT LISTS - Parens Concepts", :concept_lists => true do
  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_anon_token(@bifrost_env)

    @parens_word = 'Link (The Legend of Zelda)'
    @parens_word_2 = '24 (TV Series)'
  end

  it 'should add the parens interest' do
    # two steps: an event then interest POST

    event_url = @bifrost_env+"/events/click?deviceId=reverb-test-suite&api_key=#@session_token"
    event_body = {"events"=>[{"eventArgs"=>[{"name"=>"interestName","value"=>@parens_word},
    {"name"=>"wasEntered","value"=>@parens_word}],"eventType"=>"uAddedInterest","location"=>{"lat"=>37.785852,"lon"=>-122.406529},
    "startTime"=>Time.now.to_i*1000}]}.to_json
    begin
      response = RestClient.post event_url, event_body, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+event_url)
    end
    sleep 1

    url = @bifrost_env+"/interests?api_key="+@session_token
    begin
      response = RestClient.post url, {:value=>@parens_word,:interestType=>:interest}.to_json, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    sleep 1
  end

  it 'should display the interest in me wordwall without parens' do
    # check interest added to me wall
    url = @bifrost_env+"/trending/interests/me?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse response
    data['interests'][0]['displayName'].should == 'Link'
  end

  it 'should add the parens interest' do
    # two steps: an event then interest POST

    event_url = @bifrost_env+"/events/click?deviceId=reverb-test-suite&api_key=#@session_token"
    event_body = {"events"=>[{"eventArgs"=>[{"name"=>"interestName","value"=>@parens_word_2},
    {"name"=>"wasEntered","value"=>@parens_word_2}],"eventType"=>"uAddedInterest","location"=>{"lat"=>37.785852,"lon"=>-122.406529},
    "startTime"=>Time.now.to_i*1000}]}.to_json
    begin
      response = RestClient.post event_url, event_body, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+event_url)
    end
    sleep 1

    url = @bifrost_env+"/interests?api_key="+@session_token
    begin
      response = RestClient.post url, {:value=>@parens_word_2,:interestType=>:interest}.to_json, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    sleep 1
  end

  it 'should display the interest in me wordwall without parens' do
    # check interest added to me wall
    url = @bifrost_env+"/trending/interests/me?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse response
    data['interests'][0]['displayName'].should == '24'
  end
end
