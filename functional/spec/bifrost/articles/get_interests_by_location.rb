require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'api_checker.rb'; include APIChecker

describe "ARTICLES API -- GET Interests By Location (San Francisco SOMA)", :test => true do
  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session = get_anon_token(@bifrost_env)

    lon = '-122.392048'
    lat = '37.775044'
    lonDelta = '0.05'
    latDelta = '0.087'
    nearestLimit = '7'
    popularLimit = '12'

    url = "#@bifrost_env/articles/articlesByLocation?lon=#{lon}&lat=#{lat}&lonDelta=#{lonDelta}&latDelta=#{latDelta}"\
    "&nearestLimit=#{nearestLimit}&popularLimit=#{popularLimit}&api_key=#@session"

    puts url

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

  %w(contentId score tileType count location).each do |key|
    it "should return a non-blank, non-nil #{key} value for each tile" do
      @data['tiles'].each do |tile|
        check_not_blank tile[key]
        check_not_nil tile[key]
      end
    end
  end

  it 'should return a non-blank, non-nil count.item value for each tile' do
    @data['tiles'].each  do |tile|
      check_not_blank tile['count']['items']
      check_not_nil tile['count']['items']
    end
  end

  it 'should return only interest tiles' do
    @data['tiles'].each do |tile|
      tile['tileType'].should == 'interest'
    end
  end

  ['Moscone Center', 'San Francisco Ferry Building', 'AT&T Park'].each do |interest|
    it "should return a tile for #{interest}" do
      has_interest = false
      @data['tiles'].each do |tile|
        if tile['contentId'] == interest
          has_interest = true
          break
        end
      end
      has_interest.to_s.should == 'true'
    end

    it "should return a contentImage.url URL for tile #{interest}" do
      @data['tiles'].each do |tile|
        if tile['contentId'] == interest
          image_url = tile['contentImage']['url']
          check_not_blank image_url
          check_not_nil image_url
          image_url.match(/http/).should be_true
          break
        end
      end
    end

    it "should return a non-nil, non-blank contentImage.needsAuthentication value for tile #{interest}" do
      @data['tiles'].each do |tile|
        if tile['contentId'] == interest
          check_not_blank tile['contentImage']['needsAuthentication']
          check_not_nil tile['contentImage']['needsAuthentication']
          break
        end
      end
    end

    it "should return a non-nil, non-blank contentImage.isTransparent value for tile #{interest}" do
      @data['tiles'].each do |tile|
        if tile['contentId'] == interest
          check_not_blank tile['contentImage']['isTransparent']
          check_not_nil tile['contentImage']['isTransparent']
          break
        end
      end
    end
  end

  it 'should only return tiles with location data of lon of -122 and lat of 37' do
    @data['tiles'].each do |tile|
      tile['location']['lon'].to_i.should == -122
      tile['location']['lat'].to_i.should == 37
    end
  end
end
