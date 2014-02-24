require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'api_checker.rb'; include APIChecker

describe "SETTINGS API - Get HomeScreen For Anon User" do

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_anon_token @bifrost_env

    url = @bifrost_env+"/settings/homescreen?&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    @data = JSON.parse response
  end

  %w(homeImages interestImages trendingColors featuredArticles featuredConcepts
  featuredInterests featuredCollections quoteOfTheDay premiumPublishers urlConstants).each do |key|
    it "should return the field '#{key}'" do
      @data[key].should be_true
    end
  end

  %w(twitterLoveUrl facebookLoveUrl emailLoveUrl aboutusMoreAboutReverbUrl appstoreTwitterArticleShareUrl
    appstoreFacebookArticleShareUrl appstoreEmailArticleShareUrl appstoreMessageArticleShareUrl 
    appstoreEmailInterestCollectionShareUrl appLandingPageUrl officialAppstoreUrl caAppstoreUrl 
    appstoreLogoUrl).each do |key|
    it "should return a non-blank, non-nil 'urlConstants.#{key}' value" do
      @data['urlConstants'][key].should be_true
      check_not_blank @data['urlConstants'][key]
      check_not_nil @data['urlConstants'][key]
    end
  end
end
  