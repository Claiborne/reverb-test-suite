require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'api_checker.rb'; include APIChecker

describe "ARTICLES API - GET Articles by docId" do

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session = get_anon_token(@bifrost_env)

    # Get 24 global trending articles
    @global_trending_articles = []
    @global_trending_articles_responses = []
    res = RestClient.get "#{@bifrost_env}/trending/tiles/global?limit=24&api_key=#{@session}", @headers
    data = JSON.parse res
    data['tiles'].each do |article|
      @global_trending_articles << article['contentId'] if article['tileType'] == 'article'
    end
    @global_trending_articles.each do |article|
      res = RestClient.get "#{@bifrost_env}/articles/docId/#{article}?api_key=#{@session}", @headers
      data = JSON.parse res
      @global_trending_articles_responses << data
    end
    raise StandardError, 'Before-all failed: global trending articles less than 10' if @global_trending_articles_responses.length < 10

    # Get 24 me trending articles
    @me_trending_articles = []
    @me_trending_articles_responses = []
    res = RestClient.get "#{@bifrost_env}/trending/tiles/me?limit=24&api_key=#{@session}", @headers
    data = JSON.parse res
    data['tiles'].each do |article|
      @me_trending_articles << article['contentId'] if article['tileType'] == 'article'
    end
    @me_trending_articles.each do |article|
      res = RestClient.get "#{@bifrost_env}/articles/docId/#{article}?api_key=#{@session}", @headers
      data = JSON.parse res
      @me_trending_articles_responses << data
    end
    raise StandardError, 'Before-all failed: me trending articles less than 10' if @me_trending_articles_responses.length < 10
  end

  # global articles

  it "should return the correct docId value for each global article" do 
    @global_trending_articles_responses.each_with_index do |article, index|
      article['docId'].to_s.should == @global_trending_articles[index].to_s
    end
  end

  it "should retun a non-blank, non-nil tile value for each global article" do
    @global_trending_articles_responses.each do |article|
      title = article['title']
      check_not_blank title
      check_not_nil title
    end 
  end

  it "should retun a non-blank, non-nil summary value for each global article" do
    @global_trending_articles_responses.each do |article|
      summary = article['summary']
      check_not_blank summary
      check_not_nil summary
    end 
  end

  it "should retun a non-blank, non-nil content value for each global article" do
    @global_trending_articles_responses.each do |article|
      content = article['content']
      check_not_blank content if article['licenseType'] == 1
      check_not_nil content
    end 
  end

  it "should retun a non-blank, non-nil sourceUrl value for each global article" do
    @global_trending_articles_responses.each do |article|
      sourceUrl = article['sourceUrl']
      check_not_blank sourceUrl
      check_not_nil sourceUrl
    end 
  end

  it "should retun a non-blank, non-nil licenseType value for each global article" do
    @global_trending_articles_responses.each do |article|
      licenseType = article['licenseType']
      check_not_blank licenseType
      check_not_nil licenseType
    end 
  end

  it "should retun a non-blank, non-nil score value for each global article" do
    @global_trending_articles_responses.each do |article|
      score = article['score']
      check_not_blank score
      check_not_nil score
    end 
  end

  it "should retun a non-blank, non-nil score value for each global article" do
    @global_trending_articles_responses.each do |article|
      score = article['score']
      check_not_blank score
      check_not_nil score
    end 
  end

  it "should retun a non-blank, non-nil publisher.id value for each global article" do
    @global_trending_articles_responses.each do |article|
      publisher_id = article['publisher']['id']
      check_not_blank publisher_id
      check_not_nil publisher_id
    end 
  end

  it "should retun a non-blank, non-nil publisher.name value for each global article" do
    @global_trending_articles_responses.each do |article|
      publisher_name = article['publisher']['name']
      check_not_blank publisher_name
      check_not_nil publisher_name
    end 
  end

  it "should retun a non-blank, non-nil publisher.url value for each global article" do
    @global_trending_articles_responses.each do |article|
      publisher_url = article['publisher']['url']
      check_not_blank publisher_url
      check_not_nil publisher_url
    end 
  end

  it "should retun a non-blank, non-nil publishDate value for each global article" do
    @global_trending_articles_responses.each do |article|
      publish_date = article['publishDate']
      check_not_blank publish_date
      check_not_nil publish_date
    end 
  end

  it "should retun a non-blank, non-nil known value for each global article" do
    @global_trending_articles_responses.each do |article|
      known = article['known']
      check_not_blank known
      check_not_nil known
    end 
  end

  # me articles

  it "should return the correct docId value for each me article" do 
    @me_trending_articles_responses.each_with_index do |article, index|
      article['docId'].to_s.should == @me_trending_articles[index].to_s
    end
  end

  it "should retun a non-blank, non-nil tile value for each me article" do
    @me_trending_articles_responses.each do |article|
      title = article['title']
      check_not_blank title
      check_not_nil title
    end 
  end

  it "should retun a non-blank, non-nil summary value for each me article" do
    @me_trending_articles_responses.each do |article|
      summary = article['summary']
      check_not_blank summary
      check_not_nil summary
    end 
  end

  it "should retun a non-blank, non-nil content value for each me article" do
    @me_trending_articles_responses.each do |article|
      content = article['content']
      check_not_blank content if article['licenseType'] == 1
      check_not_nil content
    end 
  end

  it "should retun a non-blank, non-nil sourceUrl value for each me article" do
    @me_trending_articles_responses.each do |article|
      sourceUrl = article['sourceUrl']
      check_not_blank sourceUrl
      check_not_nil sourceUrl
    end 
  end

  it "should retun a non-blank, non-nil licenseType value for each me article" do
    @me_trending_articles_responses.each do |article|
      licenseType = article['licenseType']
      check_not_blank licenseType
      check_not_nil licenseType
    end 
  end

  it "should retun a non-blank, non-nil score value for each me article" do
    @me_trending_articles_responses.each do |article|
      score = article['score']
      check_not_blank score
      check_not_nil score
    end 
  end

  it "should retun a non-blank, non-nil score value for each me article" do
    @me_trending_articles_responses.each do |article|
      score = article['score']
      check_not_blank score
      check_not_nil score
    end 
  end

  it "should retun a non-blank, non-nil publisher.id value for each me article" do
    @me_trending_articles_responses.each do |article|
      publisher_id = article['publisher']['id']
      check_not_blank publisher_id
      check_not_nil publisher_id
    end 
  end

  it "should retun a non-nil publisher.name value for each me article" do
    @me_trending_articles_responses.each do |article|
      publisher_name = article['publisher']['name']
      check_not_nil publisher_name
    end 
  end

  it "should retun a non-nil publisher.url value for each me article" do
    @me_trending_articles_responses.each do |article|
      publisher_url = article['publisher']['url']
        check_not_nil publisher_url
    end 
  end

  it "should retun a non-blank, non-nil publishDate value for each me article" do
    @me_trending_articles_responses.each do |article|
      publish_date = article['publishDate']
      check_not_blank publish_date
      check_not_nil publish_date
    end 
  end

  it "should retun a non-blank, non-nil known value for each me article" do
    @me_trending_articles_responses.each do |article|
      known = article['known']
      check_not_blank known
      check_not_nil known
    end 
  end

end