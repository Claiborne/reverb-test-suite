require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'api_checker.rb'; include APIChecker

describe "SETTINGS - Get Home Screen For Anon User" do

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

  %w(twitterLoveUrl facebookLoveUrl emailLoveUrl aboutusMoreAboutReverbUrl
    appstoreFacebookArticleShareUrl appstoreEmailArticleShareUrl appstoreMessageArticleShareUrl 
    appstoreEmailInterestCollectionShareUrl appLandingPageUrl officialAppstoreUrl caAppstoreUrl 
    appstoreLogoUrl).each do |key|
    it "should return a non-blank, non-nil 'urlConstants.#{key}' value" do
      @data['urlConstants'][key].should be_true
      check_not_blank @data['urlConstants'][key]
      check_not_nil @data['urlConstants'][key]
    end
  end

  %w(myNews-FTUE-wordwall socialNews-FTUE-wordwall topNews-FTUE-wordwall myNews-FTUE-mosaic socialNews-FTUE-mosaic
    topNews-FTUE-mosaic profile-FTUE addInterest-text aboutReverb-text myNews-label socialNews-label 
    topNews-label myProfile-label).each do |key|
    it "should return an otherValues key, '#{key}'", :strict => true do
      @data['otherValues'].to_s.match("\"key\"=>\"#{key}").should be_true

    end
  end

 it "should return an iPad homescreen image for portrait and landscape that returns a 200" do
    portrait_background = @data['homeImages'][0]['portraitUrl']
    landscape_background = @data['homeImages'][0]['landscapeUrl']
    check_not_blank portrait_background
    check_not_nil portrait_background
    check_not_blank landscape_background
    check_not_nil landscape_background
    RestClient.get portrait_background
    RestClient.get landscape_background
  end

  it "should return at least 4 wordwall colors for the iPad" do
    @data['homeImages'][0]['wordColors'].length.should > 3
    @data['homeImages'][0]['wordColors'].each do |color|
      color.to_s.match(/red\"=>[0-9]{1,}/).should be_true
      color.to_s.match(/green\"=>[0-9]{1,}/).should be_true
      color.to_s.match(/blue\"=>[0-9]{1,}/).should be_true
    end
  end

  it "should return an iPhone homescreen image for portrait and landscape that returns a 200" do
    portrait_background = @data['phoneHomeImages'][0]['portraitUrl']
    landscape_background = @data['phoneHomeImages'][0]['landscapeUrl']
    check_not_blank portrait_background
    check_not_nil portrait_background
    check_not_blank landscape_background
    check_not_nil landscape_background
    RestClient.get portrait_background
    RestClient.get landscape_background
  end

  it "should return at least 4 wordwall colors for the iPhone" do
    @data['phoneHomeImages'][0]['wordColors'].length.should > 3
    @data['phoneHomeImages'][0]['wordColors'].each do |color|
      color.to_s.match(/red\"=>[0-9]{1,}/).should be_true
      color.to_s.match(/green\"=>[0-9]{1,}/).should be_true
      color.to_s.match(/blue\"=>[0-9]{1,}/).should be_true
    end
  end

  it "should return a non-nil, non-blank value for each value in 'otherValues'" do
    @data['otherValues'].each do |otherValue|
      otherValue['value'].should_not be_nil
      otherValue['value'].delete("^a-zA-Z").length.should > 0
    end
  end
end
  