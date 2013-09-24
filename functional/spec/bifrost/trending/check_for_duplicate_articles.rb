require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'  

describe "TRENDING API -- Get 300 Articles With Anon User", :test => true do

  class Get_300_Helpers
    class << self; attr_accessor :me, :global; end
  end

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_anon_token(@bifrost_env) 
  end

  it 'should get 300 global articles' do
    articles = []
    %w(0 20 40 60 80 100 120 140 160 180 200 220 240 260 280 300).each do |skip|
      url = @bifrost_env+"/trending/tiles/global?skip=#{skip}&limit=20&api_key="+@session_token
      begin
        response = RestClient.get url, @headers
      rescue => e
        raise StandardError.new(e.message+" "+url)
      end
      @data = JSON.parse response
      #puts @data['tiles'].length
      @data['tiles'].each do |a|
        articles << a['contentId']
      end
    end
    Get_300_Helpers.global = articles
    articles.length.should == 300
  end

  it 'should not return duplicates global articles' do
    (Get_300_Helpers.global.select{ |e| Get_300_Helpers.global.count(e) > 1 }).uniq.should == []
  end

  it 'should get 300 me articles' do
    articles = []
    %w(20 40 60 80 100 120 140 160 180 200 220 240 260 280 300).each do |skip|
      url = @bifrost_env+"/trending/tiles/me?skip=#{skip}&limit=20&api_key="+@session_token
      begin
        response = RestClient.get url, @headers
      rescue => e
        raise StandardError.new(e.message+" "+url)
      end
      @data = JSON.parse response
      #puts @data['tiles'].length
      @data['tiles'].each do |a|
        articles << a['contentId']
      end
    end
    Get_300_Helpers.me = articles
    articles.length.should == 300
  end

  it 'should not return duplicate me articles' do
    (Get_300_Helpers.me.select{ |e| Get_300_Helpers.me.count(e) > 1 }).uniq.should == []
  end
end
