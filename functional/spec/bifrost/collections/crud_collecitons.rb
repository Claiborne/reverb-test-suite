require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'api_checker.rb'

include APIChecker

describe "USER FLOWS - CRUD Collections", :collections => true, :stg => true, :indev => true do

  class CollectionFlowHelper
    class << self; attr_accessor :collection; end
  end

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    login = get_token_and_login @bifrost_env, 'clay01', 'testpassword'
    @session = login[0]
    @user_id = login[1]
    @anon_session = get_anon_token @bifrost_env

    @collection_name = "claytest#{Random.rand 1000000000}"

    # Get an array of articles
    news_tiles_url = @bifrost_env+"/trending/tiles/global?skip=0&limit=24&api_key="+@session
    begin
      res = RestClient.get news_tiles_url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+news_tiles_url)
    end
    news_tiles = JSON.parse res
    @article_ids = []
    news_tiles['tiles'].each do |tile|
      @article_ids << tile['contentId'].to_i unless tile['tileType'] == 'interest'
    end
  end

  it "should create a collection" do
    url = @bifrost_env+"/collections?api_key="+@session
    body = {
              :collection_name=>@collection_name,
              :articles=>[@article_ids[0]],
              :pinnedConcepts=>[
                "Knitting", "Cake"
              ],
              :summary=>"this is the summary"
            }.to_json
    begin 
      response = RestClient.post url, body, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    CollectionFlowHelper.collection = JSON.parse response
  end

  it 'should create a collection with the approriate name' do
    CollectionFlowHelper.collection['name'].should == @collection_name
  end

  it 'should create a collection with the appropriate number of tiles' do
    CollectionFlowHelper.collection['tiles'].count.should == 1
  end

  it 'should create a collection with the appropriate article' do
    CollectionFlowHelper.collection['tiles'][0]['contentId'].should == @article_ids[0].to_s
  end

  it 'should create a collection with the appropriate pinnedConcepts' do
    pinned_concepts = ["Knitting", "Cake"]
    CollectionFlowHelper.collection['contentPreferences']['pinnedConcepts'].should == pinned_concepts
  end

  it 'should create a collection with the appropriate summary' do
    CollectionFlowHelper.collection['summary'].should == 'this is the summary'
  end

  it 'should get colleciton by ID' do
    id = CollectionFlowHelper.collection['id']
    url = @bifrost_env+"/collections/#{id}?api_key="+@session
    begin 
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)

    end
    data = JSON.parse response
    data['name'].should == @collection_name
    data['id'].should == id
  end

  it 'should add an article to a collection' do
    id = CollectionFlowHelper.collection['id']
    article1 = @article_ids[1]
    article2 = @article_ids[2]
    body = {:articlesToAdd=>[article1,article2]}.to_json
    url = @bifrost_env+"/collections/#{id}/config?api_key="+@session
    begin
      response = RestClient.put url, body, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    articles = []
    data['tiles'].each do |tile|
      articles << tile['contentId']
    end
    articles.include?(article1.to_s).should be_true
    articles.include?(article2.to_s).should be_true

    # Now do a get and make same assertions
    url = @bifrost_env+"/collections/#{id}?api_key="+@session
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    articles = []
    data['tiles'].each do |tile|
      articles << tile['contentId']
    end
    articles.include?(article1.to_s).should be_true
    articles.include?(article2.to_s).should be_true
  end

  it 'should remove an article from a collection' do
    id = CollectionFlowHelper.collection['id']
    article1 = @article_ids[1]
    article2 = @article_ids[2]
    body = {:articlesToRemove=>[article1,article2]}.to_json
    url = @bifrost_env+"/collections/#{id}/config?api_key="+@session
    begin
      response = RestClient.put url, body, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    tiles = []
    data['tiles'].each do |tile|
      tiles << tile['contentId']
    end
    tiles.include?(article1.to_s).should be_false
    tiles.include?(article2.to_s).should be_false

    # Now do a get and make same assertions
    url = @bifrost_env+"/collections/#{id}?api_key="+@session
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    tiles = []
    data['tiles'].each do |tile|
      tiles << tile['contentId']
    end
    tiles.include?(article1.to_s).should be_false
    tiles.include?(article2.to_s).should be_false
  end

  it 'should add an interest to a collection' do
    id = CollectionFlowHelper.collection['id']
    interest1 = 'San Francisco'
    interest2 = 'Seattle'
    body = {:pinnedInterestsToAdd=>[interest1,interest2]}.to_json
    url = @bifrost_env+"/collections/#{id}/config?api_key="+@session
    begin
      response = RestClient.put url, body, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    interests = []
    data['contentPreferences']['pinnedConcepts'].each do |interest|
      interests << interest
    end
    interests.include?(interest1).should be_true
    interests.include?(interest2).should be_true

    # Now do a get and make same assertions
    url = @bifrost_env+"/collections/#{id}?api_key="+@session
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    interests = []
    data['contentPreferences']['pinnedConcepts'].each do |interest|
      interests << interest
    end
    interests.include?(interest1).should be_true
    interests.include?(interest2).should be_true
  end

  it 'should remove an interest from a collection' do
    id = CollectionFlowHelper.collection['id']
    interest1 = 'San Francisco'
    interest2 = 'Seattle'
    body = {:pinnedInterestsToRemove=>[interest1,interest2]}.to_json
    url = @bifrost_env+"/collections/#{id}/config?api_key="+@session
    begin
      response = RestClient.put url, body, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    interests = []
    data['contentPreferences']['pinnedConcepts'].each do |interest|
      interests << interest
    end
    interests.include?(interest1).should be_false
    interests.include?(interest2).should be_false

    # Now do a get and make same assertions
    url = @bifrost_env+"/collections/#{id}?api_key="+@session
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    interests = []
    data['contentPreferences']['pinnedConcepts'].each do |interest|
      interests << interest
    end
    interests.include?(interest1).should be_false
    interests.include?(interest2).should be_false
  end

  it "should modify a collection's name and summary" do
    id = CollectionFlowHelper.collection['id']
    modified_name = 'modified name'
    modified_summary = 'modified_summary'
    body = {:name=>modified_name,:summary=>modified_summary}.to_json
    url = @bifrost_env+"/collections/#{id}/config?api_key="+@session
    begin
      response = RestClient.put url, body, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    data['name'].should == modified_name
    data['summary'].should == modified_summary

    # Now do a get and make same assertions
    url = @bifrost_env+"/collections/#{id}?api_key="+@session
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    data = JSON.parse response
    data['name'].should == modified_name
    data['summary'].should == modified_summary
  end

  it 'should prevent others from adding an article to a collection you created' do
    id = CollectionFlowHelper.collection['id']
    article = @article_ids[3]
    body = {:articlesToAdd=>[article]}.to_json
    url = @bifrost_env+"/collections/#{id}/config?api_key="+@anon_session
    begin
      response = RestClient.put url, body, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    articles = []
    data['tiles'].each do |tile|
      articles << tile['contentId']
    end
    articles.include?(article.to_s).should be_false

    # Now do a get and make same assertions
    url = @bifrost_env+"/collections/#{id}?api_key="+@session
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    articles = []
    data['tiles'].each do |tile|
      articles << tile['contentId']
    end
    articles.include?(article.to_s).should be_false
  end

  it 'should not allow another user to delete your collection' do
    collection_id = CollectionFlowHelper.collection['id']
    url = @bifrost_env+"/collections/#{collection_id}?api_key="+@anon_session
    expect {RestClient.delete url, @headers}.to raise_error(RestClient::BadRequest)
  end

  it 'should delete collection' do
    collection_id = CollectionFlowHelper.collection['id']
    url = @bifrost_env+"/collections/#{collection_id}?api_key="+@session
    begin 
      response = RestClient.delete url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
  end

  it 'should return a 404 when deleted collection is requested by ID' do
    sleep 1
    id = CollectionFlowHelper.collection['id']
    url = @bifrost_env+"/collections/#{id}?api_key="+@session
    expect {RestClient.get url, @headers}.to raise_error(RestClient::ResourceNotFound)
  end
end
