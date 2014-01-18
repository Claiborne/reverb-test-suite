require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'colorize'

include Token

describe "CONCEPT LISTS - Grey-listed Concepts" do
  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_anon_token(@bifrost_env)

    @grey_listed_word = 'Grep'
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
    url = @bifrost_env+"/interests?api_key="+@session_token
    begin
      response = RestClient.post url, {:value=>@grey_listed_word,:interestType=>:interest}.to_json, @headers
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
    me_wall.include?(@grey_listed_word).should be_false
  end

  xit 'should not display the interest in me tiles (THIS RETURNS FALSE POSITIVE B/C RVB-4658)' do
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
    me_tiles.include?(@grey_listed_word).should be_false
  end

end
