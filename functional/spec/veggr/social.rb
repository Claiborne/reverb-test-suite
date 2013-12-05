require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'; include Token

### NOTE: This is hardcoded for stage only right now ####

describe "VEGGR SOCIAL - Social Shares" do

  class Veggr_Helper
    @social_interests = []
    class << self; attr_accessor :social_interests; end
  end

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Get veggr social environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../config/veggr_social.yml"
    @veggr_social_env = "http://#{ConfigPath.new.options['baseurl']}:8000"

    # Get veggr service environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../config/veggr_service.yml"
    @veggr_service_env = "http://#{ConfigPath.new.options['baseurl']}:8000"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_token @bifrost_env, 'clay_social', 'testpassword'
  end

  it 'should delete a user\'s sifter' do
    url = "#@veggr_service_env/api/cache/users/socialSifter/152867"
    begin
      res = RestClient.delete url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
  end

  it 'should start with a blank social wall' do
    url = "#@bifrost_env/trending/interests/social?skip=0&api_key=#@session_token"
    puts url
    begin
      res = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse res
    data['interests'].length.should == 0
  end

  it 'should start with blank social tiles' do
    url = "#@bifrost_env/trending/tiles/social?skip=0&api_key=#@session_token"
    begin
      res = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse res
    data['tiles'].length.should == 0
  end

  it 'should post a share event to baldr' do
    article = '40000010'
    affected_user = [152867] # clay_social
    user_who_shared = 153008 # clay_share

    body = {
      "eventName"=>"com.reverb.events.heimdall.shares.ContentShared",
      "sharedContent"=>[{
        "eventName"=>"com.reverb.events.ContentShare",
        "itemType"=>"article",
        "itemId"=>article,
        "attribution"=>{
          "eventName"=>"com.reverb.datacontracts.Attribution",
          "network"=>"reverb",
          "shareDate"=>"2013-11-26T07:33:15Z",
          "userId"=>user_who_shared
        }
      }],
      "affectedUsers"=>affected_user
    }.to_json

    url = "#@veggr_social_env/api/baldr/notify/heimdall-background-service/shares"
    RestClient.post url, body, @headers
  end

  it 'should have content on user\'s social wall after baldr share' do
    url = "#@bifrost_env/trending/interests/social?skip=0&api_key=#@session_token"
    begin
      res = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse res
    data['interests'].length.should > 0

    data['interests'].each do |interest|
      Veggr_Helper.social_interests << interest['value']
    end
  end

  it 'should have content on user\'s social tiles after baldr share' do
    url = "#@bifrost_env/trending/tiles/social?skip=0&api_key=#@session_token"
    begin
      res = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse res
    data['tiles'].length.should > 0
  end

  it 'should have contnent for each social word after baldr share' do
    Veggr_Helper.social_interests.each do |social_interest|
      url = "#@bifrost_env/interests/stream/social?interest=#{CGI::escape social_interest}&api_key=#@session_token"
      begin
        res = RestClient.get url, @headers
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
    data = JSON.parse res
    data['tiles'].length.should > 0
    end
  end
end
