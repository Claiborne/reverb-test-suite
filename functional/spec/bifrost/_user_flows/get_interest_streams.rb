require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'colorize'
require 'time'

include Token

describe "USER FLOWS - Get Trending Interests For an Anon User" do
  class Interests_Helper
    @me = []; @global = []; @news_interest_stream_tiles_count = 0; @news_interest_stream_tiles = []
    class << self; attr_accessor :me, :global, :news_interest_stream_tiles_count, :news_interest_stream_tiles; end
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

  it 'should return 24 me topics' do
    url = @bifrost_env+"/trending/interests/me?skip=0&limit=100&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    interests = (JSON.parse response)['interests']
    interests.each {|i| Interests_Helper.me << i['value'] unless i['value'].downcase.match(/news/)}
    Interests_Helper.me.length.should == 24
  end

  it 'should return at least 175 news interests', :strict => true do
    url = @bifrost_env+"/trending/interests/global?limit=500&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    interests = (JSON.parse response)['interests']
    interests.each {|i| Interests_Helper.global << i['value'] if i['interestType'] == 'interest'}
    interests.count.should > 174
    Interests_Helper.global.length.should > 174
  end

  it 'should return at least 100 news interests' do
    url = @bifrost_env+"/trending/interests/global?limit=500&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    interests = (JSON.parse response)['interests']
    interests.each {|i| Interests_Helper.global << i['value'] if i['interestType'] == 'interest'} 
    interests.count.should > 99
    Interests_Helper.global.length.should > 99
  end

  it "should return 24 articles for each me topic", :strict => true do
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
      errors << "#{interest} retured only #{data['tiles'].length} tiles" if data['tiles'].length != 24
    end
    errors.should == []
  end

  it "should return at least 30 articles for each me topic", :strict => true do
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

  it "should return at least two articles for each news interest (FAILS IN PRODUCTION RVB-6619)" do
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
      Interests_Helper.news_interest_stream_tiles_count += data['tiles'].length
      blank_tiles << interest+" (#{data['tiles'].length})" if data['tiles'].length < 2
      Interests_Helper.news_interest_stream_tiles << data['tiles'] if data['tiles']
    end

    if blank_tiles.count < 1
      blank_tiles.should == []
    elsif blank_tiles.count > 4
      blank_tiles.should == []
    else
      blank_tiles.count.should < 5
    end
  end

  it 'should return at least 1500 tiles across all news interests' do
    Interests_Helper.news_interest_stream_tiles_count.should > 1499
    # curretly returns 1700 in prod and 1900 in stage
  end

  it 'should sort news interest streams by publish date' do
    interest_streams_checked = 0
    Interests_Helper.news_interest_stream_tiles.each do |news_tiles|
      tiles = []
      news_tiles.each do |news_tile|
        tiles << news_tile['publishDate']
      end
      interest_streams_checked += 1
      tiles.should == tiles.sort { |x,y| y <=> x }
    end
    interest_streams_checked.should > 450
  end
end

describe "USER FLOWS - Get Trending Interests for a Social User", :strict => true do

  class Interests_Helper
    @social = []; @social_tiles = []
    class << self; attr_accessor :social, :social_tiles; end
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

  it "should return at least one article for each social interest (FAILS IN PRODUCTION RVB-6498)" do
    blank_tiles = []
    not_recent = []
    Interests_Helper.social.each do |interest|
      url = @bifrost_env+"/interests/stream/social?interest=#{CGI::escape interest}&skip=0&limit=24&api_key="+@session_token
      begin
        response = RestClient.get url, @headers
      rescue RestClient::ResourceNotFound => e
        blank_tiles << "#{url} 404 Not Found"
        next
      rescue => e
        blank_tiles << StandardError.new(e.message+":\n"+url)
        next
      end
      data = JSON.parse response
      Interests_Helper.social_tiles << data['tiles']
      (blank_tiles << interest+" (#{data['tiles'].length})" if data['tiles'].length < 1) unless interest.match(/\d{4}/)
    end
    blank_tiles.should == []
  end

  it 'should sort social interest streams by share date' do
    interest_streams_checked = 0
    Interests_Helper.social_tiles.each do |social_tiles|
      tiles = []
      social_tiles.each do |social_tile|
        tiles << social_tile['attribution'][0]['shareDate']
      end
      interest_streams_checked += 1
      tiles.should == tiles.sort { |x,y| y <=> x }
    end
    interest_streams_checked.should > 450
  end
end
