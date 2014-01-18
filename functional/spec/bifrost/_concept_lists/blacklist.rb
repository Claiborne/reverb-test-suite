require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'colorize'

include Token

describe "CONCEPT LISTS - Black-listed Concepts" do

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_anon_token(@bifrost_env)

    @black_listed_word = 'Rape'
  end

  it 'should not appear as a tile when searched for' do
    blocked_interest = @black_listed_word
    url = @bifrost_env+"/interests/search/#{blocked_interest}?limit=10&api_key="+@session_token
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
    search_results.include?(blocked_interest).should be_false
  end
=begin
  it 'should add an interest' do
    url = @bifrost_env+"/interests?api_key="+@session_token
    begin
      response = RestClient.post url, {:value=>@interest,:interestType=>:interest}.to_json, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
  end

  xit 'should display the interest in me wordwall' do
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

  xit 'should display the interest in me tiles (FAILS IN PRODUCTION RVB-4658)' do
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
=end
end
