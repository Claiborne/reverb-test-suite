require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'api_checker.rb'; include APIChecker

describe "ARTICLES API -- GET Articles By Location (San Francisco)", :test => true do

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session = get_anon_token(@bifrost_env)

    lon = '-122.424'
    lat = '37.775'
    lonDelta = '0.3'
    latDelta = '0.3'
    nearestLimit = '10'
    popularLimit = '10'

    url = "#@bifrost_env/articles/articlesByLocation?lon=#{lon}&lat=#{lat}&lonDelta=#{lonDelta}&latDelta=#{latDelta}"\
    "&nearestLimit=#{nearestLimit}&popularLimit=#{popularLimit}&api_key=#@session"

    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end

    @data = JSON.parse response
  end

  it 'should return at least five tiles' do
    @data['tiles'].count.should > 4
  end

  it 'should rertun at least one article' do
    article_returned = false
    @data['tiles'].each do |tile|
      article_returned = true if tile['tileType'] == 'article'
    end
    article_returned.to_s.should == 'true'
  end

  it 'should return at least one interest' do
    interest_returned = false
    @data['tiles'].each do |tile|
      interest_returned = true if tile['tileType'] == 'interest'
    end
    interest_returned.to_s.should == 'true'
  end

  # check articles

  #check tiles

  #%w(contentId score titleType count location)
end
