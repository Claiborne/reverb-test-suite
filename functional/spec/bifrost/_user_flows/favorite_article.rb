require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'colorize'

include Token

describe "USER FLOWS - Favorite an article", :test => true do
  
  class Fav_Article_Helper
    @article = nil
    class << self; attr_accessor :article; end
  end

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Sign in
    login = get_token_and_login @bifrost_env, 'clay01
', 'testpassword'
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
    data['tiles'][0].should == article
  end

  it "should remove an article from favorites" do
    article = Fav_Article_Helper.article
    url = @bifrost_env+"/userProfile/reverb?item=#{article}&type=article&api_key="+@session_token
    begin
      response = RestClient.delete url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
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
    data['tiles'][0].should != article
  end
end
