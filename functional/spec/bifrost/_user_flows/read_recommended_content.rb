require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'api_checker.rb'; include APIChecker

describe "USER FLOWS - Read Recommended Content", :read_recommended => true do

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session = get_anon_token(@bifrost_env)

    # Get a global trending article
    res = RestClient.get @bifrost_env+"/trending/tiles/global?limit=24&api_key="+@session, @headers
    @article_id = JSON.parse(res)['tiles'][0]['contentId']

    url = @bifrost_env+"/articles/recommendations/#@article_id?api_key="+@session
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end

    @recommended_articles = JSON.parse response
  end

  it 'should return at least three tile recomendations' do
    @recommended_articles['tiles'].count.should > 2
  end

  it 'should return at least one article tile' do
    article_returned = false
    @recommended_articles['tiles'].each do |tile|
      if tile['tileType'] == 'article'
        article_returned = true
        break
      end
    end
    article_returned.to_s.should == 'true'
  end

  it 'should return at least one interest tile' do
    article_returned = false
    @recommended_articles['tiles'].each do |tile|
      if tile['tileType'] == 'interest'
        article_returned = true
        break
      end
    end
    article_returned.to_s.should == 'true'
  end

  # check article tiles

  %w(contentId score tileType header summary publisherInfo publishDate known shareUrl).each do |key|
    it "should return a non-blank, non-nil #{key} value for each article" do
      @recommended_articles['tiles'].each do |article|
        if article['tileType'] == 'article'
          check_not_blank article[key]
          check_not_nil article[key]
        end
      end
    end
  end

  it "should return a non-blank, non-nil publisherInfo.id value for each article" do
    @recommended_articles['tiles'].each do |article|
      if article['tileType'] == 'article'
        check_not_blank article['publisherInfo']['id']
        check_not_nil article['publisherInfo']['id']
      end  
    end
  end

  # check interest tiles 

  %w(contentId score tileType count known shareUrl).each do |key|
    it "should return a non-blank, non-nil #{key} value for each interest" do
      @recommended_articles['tiles'].each do |interest|
        if interest['tileType'] == 'interest'
          check_not_blank interest[key]
          check_not_nil interest[key]
        end
      end
    end
  end

  it 'should return a non-blank, non-nil count.items value for each interest' do
    @recommended_articles['tiles'].each do |interest|
      if interest['tileType'] == 'interest'
        check_not_blank interest['count']['items']
        check_not_nil interest['count']['items']
      end
    end
  end

  # open recommended articles 

  it 'should open each recommended article' do
    @recommended_articles['tiles'].each do |article|
      if article['tileType'] == 'article'
        article_id = article['contentId']
        url = @bifrost_env+"/articles/docId/#{article_id}?api_key="+@session
        begin
          response = RestClient.get url, @headers
        rescue => e
          raise StandardError.new(e.message+":\n"+url)
        end
      end
    end
  end

  # open recommended interests 

  it 'should open each recommended interests' do
    @recommended_articles['tiles'].each do |interest|
      if interest['tileType'] == 'interest'
        interest_name = interest['contentId']
        url = @bifrost_env+"/interests/stream/me?interest=#{CGI::escape interest_name}&skip=0&limit=24&api_key="+@session
        begin
          response = RestClient.get url, @headers
        rescue => e
          raise StandardError.new(e.message+":\n"+url)
        end
      end
    end
  end

end
  