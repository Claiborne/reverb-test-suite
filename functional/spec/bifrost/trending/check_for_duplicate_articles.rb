require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'

['Anon User', 'Logged in User'].each do |usr|
describe "TRENDING API -- Get 300 Articles With #{usr}" do

  class Get_300_Helpers
    class << self; attr_accessor :me, :global, :me_titles, :global_titles; end
  end

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    if usr = 'Logged in User'
      @session_token = get_token(@bifrost_env, 'clay00', 'testpassword') 
    else
      @session_token = get_anon_token(@bifrost_env) 
    end
  end

  it 'should get 300 global articles' do
    articles = []; article_titles = []
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
        article_titles << a['header']['value']
      end
    end
    Get_300_Helpers.global = articles
    Get_300_Helpers.global_titles = article_titles
    articles.length.should == 300
    article_titles.length.should == 300
  end

  it 'should not return duplicates global articles by ID' do
    (Get_300_Helpers.global.select{ |e| Get_300_Helpers.global.count(e) > 1 }).uniq.should == []
  end

    it 'should not return duplicates global articles by title' do
    (Get_300_Helpers.global_titles.select{ |e| Get_300_Helpers.global_titles.count(e) > 1 }).uniq.should == []
  end

  it 'should get 300 me articles' do
    articles = []; article_titles = []
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
        article_titles << a['header']['value']
      end
    end
    Get_300_Helpers.me = articles
    Get_300_Helpers.me_titles = article_titles
    articles.length.should == 300
    article_titles.length.should == 300
  end

  it 'should not return duplicate me articles by ID' do
    (Get_300_Helpers.me.select{ |e| Get_300_Helpers.me.count(e) > 1 }).uniq.should == []
  end

    it 'should not return duplicate me articles by title' do
    (Get_300_Helpers.me_titles.select{ |e| puts e; puts ''; Get_300_Helpers.me_titles.count(e) > 1 }).uniq.should == []
  end
end; end
