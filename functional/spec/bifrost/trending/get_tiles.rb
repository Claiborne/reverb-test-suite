require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'

%w(0 50 100 150).each do |skip|
  describe "TRENDING API -- Get 'Me' Articles For Anon User" do

    before(:all) do
      # Get bifrost environment
      ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
      @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

      # Set headers
      @headers = {:content_type => 'application/json', :accept => 'application/json'}

      # Get anon session token
      @session_token = get_anon_token(@bifrost_env) 

      # Get Articles for Anon User
      url = @bifrost_env+"/trending/tiles/me?#{skip}=0&limit=100&api_key="+@session_token
      begin
        response = RestClient.get url, @headers
      rescue => e
        raise StandardError.new(e.message+" "+url)
      end
      @data = JSON.parse response
    end

    it "should get 24 'me' articles" do
      @data['tiles'].length.should == 24
    end

    it "should only return articles of type 'article'" do
      @data['tiles'].each do |i|
        i['tileType'].should == 'article'
      end
    end

    it 'should not return any duplicates' do
      interest_values = []
      @data['tiles'].each do |i|
        interest_values << i['contentId']
      end
      interest_values.should == interest_values.uniq
    end
  end
end

%w(0 50 100 150).each do |skip|
  describe "TRENDING API -- Get 'Global' Articles For Anon User" do

    before(:all) do
      # Get bifrost environment
      ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
      @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

      # Set headers
      @headers = {:content_type => 'application/json', :accept => 'application/json'}

      # Get anon session token
      @session_token = get_anon_token(@bifrost_env) 

      # Get Articles for Anon User
      url = @bifrost_env+"/trending/tiles/global?#{skip}=0&limit=100&api_key="+@session_token
      begin
        response = RestClient.get url, @headers
      rescue => e
        raise StandardError.new(e.message+" "+url)
      end
      @data = JSON.parse response
    end

    it "should get 24 'global' articles" do
      @data['tiles'].length.should == 24
    end

    it "should only return interests of type 'article'" do
      @data['tiles'].each do |i|
        i['tileType'].should == 'article'
      end
    end

    it 'should not return any duplicates' do
      interest_values = []
      @data['tiles'].each do |i|
        interest_values << i['contentId']
      end
      interest_values.should == interest_values.uniq
    end
  end
end
