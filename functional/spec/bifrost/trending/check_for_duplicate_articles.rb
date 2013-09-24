require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'  

describe "TRENDING API -- Get 300 Articles With Anon User" do

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
    %w(20 40 60 80 100 120 140 160 180 200 220 240 260 280 300).each do |skip|
      url = @bifrost_env+"/trending/tiles/global?#{skip}=0&limit=20&api_key="+@session_token
      begin
        response = RestClient.get url, @headers
      rescue => e
        raise StandardError.new(e.message+" "+url)
      end
      @data = JSON.parse response
      @data.each do |a|
        articles << a['contentId']
    end
    articles.length.should == 300
    Get_300_Helpers.global = articles
  end

  it 'should not return duplicates' do
    Get_300_Helpers.global.should == Get_300_Helpers.global.uniq
  end

  it 'should get 300 me articles' do
    articles = []
    %w(20 40 60 80 100 120 140 160 180 200 220 240 260 280 300).each do |skip|
      url = @bifrost_env+"/trending/tiles/me?#{skip}=0&limit=20&api_key="+@session_token
      begin
        response = RestClient.get url, @headers
      rescue => e
        raise StandardError.new(e.message+" "+url)
      end
      @data = JSON.parse response
      @data.each do |a|
        articles << a['contentId']
    end
    articles.length.should == 300
    Get_300_Helpers.me = articles
  end

  it 'should not return duplicates' do
    Get_300_Helpers.me.should == Get_300_Helpers.me.uniq
  end

end
  
