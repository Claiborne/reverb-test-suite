require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'colorize'

include Token

describe "USER FLOWS - Favorite and unfavorite an article", :favs => true do
  
  class Fav_Article_Helper
    class << self; attr_accessor :article, :favorite_count; end
  end

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Sign in
    login = get_token_and_login @bifrost_env, 'clay01', 'testpassword'
    @session_token = login[0]
    @user_id = login[1]
  end

  it 'should get an article' do
    url = @bifrost_env+"/trending/tiles/global?skip=0&limit=24&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse response
    data['tiles'].each do |tile|
      if tile['tileType'] == 'article'
        Fav_Article_Helper.article = tile['contentId']
        break
      else
      end
    end
    Fav_Article_Helper.article.should_not be_nil
  end

  it 'should get favorite count from profile' do
    url = @bifrost_env+"/userProfile/mine?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse response
    Fav_Article_Helper.favorite_count = data['stats']['reverbedItems']
  end

  it 'should favorite an article' do
    article = Fav_Article_Helper.article
    article.should_not be_nil
    url = @bifrost_env+"/userProfile/reverb?api_key="+@session_token
    body = {:contentId=>"#{article}",:contentType=>'article'}.to_json
    begin
      response = RestClient.post url, body, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    sleep 2
  end

  it "should return favorited article" do
    article = Fav_Article_Helper.article
    url = @bifrost_env+"/userProfile/reverbs/#@user_id?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse response
    data['tiles'][0]['contentId'].should == article
  end

  it 'should increase favorite count from profile by one' do
    url = @bifrost_env+"/userProfile/mine?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse response
    data['stats']['reverbedItems'].should == Fav_Article_Helper.favorite_count+1
  end

  it "should remove an article from favorites" do
    article = Fav_Article_Helper.article
    url = @bifrost_env+"/userProfile/reverb?item=#{article}&type=article&api_key="+@session_token
    begin
      response = RestClient.delete url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    sleep 2
  end

  it "should not return unfavorited article" do
    article = Fav_Article_Helper.article
    url = @bifrost_env+"/userProfile/reverbs/#@user_id?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse response
    data['tiles'][0]['contentId'].should_not == article
  end

  it 'should descrease favorite count from profile by one' do
    url = @bifrost_env+"/userProfile/mine?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse response
    data['stats']['reverbedItems'].should == Fav_Article_Helper.favorite_count
  end
end

describe "USER FLOWS - Favorite and unfavorite an interest", :favs => true do
  
  class Fav_Interest_Helper
    class << self; attr_accessor :interest, :favorite_count; end
  end

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Sign in
    login = get_token_and_login @bifrost_env, 'clay01', 'testpassword'
    @session_token = login[0]
    @user_id = login[1]
  end

  it 'should get favorite count from profile' do
    url = @bifrost_env+"/userProfile/mine?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse response
    Fav_Interest_Helper.favorite_count = data['stats']['reverbedItems']
  end

  it 'should get an interest' do
    url = @bifrost_env+"/trending/interests/global?skip=0&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse response
    begin
      interest = data['interests'][Random.rand(100)]['value']
      Fav_Interest_Helper.interest = [CGI::escape(interest), interest]
    rescue
      interest = data['interests'][Random.rand(23)]['value']
      Fav_Interest_Helper.interest = [CGI::escape(interest), interest]
    end
    Fav_Interest_Helper.interest.should_not be_nil
  end

  it 'should favorite an interest' do
    interest = Fav_Interest_Helper.interest
    interest.should_not be_nil
    url = @bifrost_env+"/userProfile/reverb?api_key="+@session_token
    body = {:contentId=>"#{interest[1]}",:contentType=>'interest'}.to_json
    begin
      response = RestClient.post url, body, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    sleep 2
  end

  it 'should appear favorited in the interest streams (me & global)' do
    interest = Fav_Interest_Helper.interest
    url = @bifrost_env+"/interests/stream/me?interest=#{interest[0]}&api_key="+@session_token
    begin
      res = response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse res
    data['known'].to_s.should == 'true'

    url = @bifrost_env+"/interests/stream/global?interest=#{interest[0]}&api_key="+@session_token
    begin
      res = response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse res
    data['known'].to_s.should == 'true'
  end

  it "should return favorited interest (FAILS INTERMITTENTLY IN PROD RVB-5295)" do 
    interest = Fav_Interest_Helper.interest[1]
    url = @bifrost_env+"/userProfile/reverbs/#@user_id?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse response
    data['tiles'][0]['contentId'].should == interest
  end

  it 'should increase favorite count from profile by one' do
    url = @bifrost_env+"/userProfile/mine?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse response
    data['stats']['reverbedItems'].should == Fav_Interest_Helper.favorite_count+1
  end

  it "should remove an interest from favorites" do
    interest = Fav_Interest_Helper.interest[0]
    url = @bifrost_env+"/userProfile/reverb?item=#{interest}&type=interest&api_key="+@session_token
    begin
      response = RestClient.delete url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    sleep 2
  end

  it "should not return unfavorited interest" do
    interest = Fav_Interest_Helper.interest[1]
    url = @bifrost_env+"/userProfile/reverbs/#@user_id?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse response
    data['tiles'][0].should_not == interest
  end

  it 'should descrease favorite count from profile by one' do
    url = @bifrost_env+"/userProfile/mine?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse response
    data['stats']['reverbedItems'].should == Fav_Interest_Helper.favorite_count
  end
end
