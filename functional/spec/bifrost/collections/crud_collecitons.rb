require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'api_checker.rb'

include APIChecker

describe "COLLECTIONS - CRUD Collections", :collections => true, :crud => true do

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

    @interest_one = 'Knitting'
    @interest_two = 'Cake'
    @interest_three = 'California'
    @interest_four = 'New York'
    @interest_five = 'Apple'

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
      @article_ids << tile['contentId'].to_i if tile['tileType'] == 'article'
    end
  end

  it "should create a collection" do
    url = @bifrost_env+"/collections?api_key="+@session
    body = {
              :collection_name=>@collection_name,
              :articles=>[@article_ids[0]],
              :pinnedConcepts=>[
                @interest_one, @interest_two
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
    CollectionFlowHelper.collection['tiles'].count.should == 3
  end

  it 'should create a collection with the appropriate article tiles' do
    tiles = []
    CollectionFlowHelper.collection['tiles'].each do |tile|
      tiles << tile['contentId']
    end
    tiles.should include @article_ids[0].to_s
  end

  it 'should create a collection with the appropriate interest tiles' do
    tiles = []
    CollectionFlowHelper.collection['tiles'].each do |tile|
      tiles << tile['contentId']
    end
    tiles.should include @interest_one
    tiles.should include @interest_two
  end

  it 'should create a collection with the appropriate pinnedConcepts' do
    pinned_concepts = [@interest_one, @interest_two]
    CollectionFlowHelper.collection['contentPreferences']['pinnedConcepts'].should == pinned_concepts
  end

  it 'should create a collection with the appropriate summary' do
    CollectionFlowHelper.collection['summary'].should == 'this is the summary'
  end

  it 'should create a collection with a contentImage.url value' do
    CollectionFlowHelper.collection['contentImage']['url'].match(/images.helloreverb.com\/api\/image/).should be_true
  end

  it 'should create a collecion with a contentImage.url value that 200s when requested' do
    image_url = CollectionFlowHelper.collection['contentImage']['url']
    begin 
      res = RestClient.get image_url+"&api_key=#@session"
     rescue => e
      raise StandardError.new(e.message+" "+image_url)
    end
  end

  it 'should create a collection with known = false' do
    CollectionFlowHelper.collection['known'].should == false
  end

  it "should create a collection with a flag of 'public'" do
    CollectionFlowHelper.collection['flags'].should == ['public']
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

  it 'should add three articles to a collection and return them in the same order added' do
    id = CollectionFlowHelper.collection['id']
    article1 = @article_ids[2]
    article2 = @article_ids[1]
    article3 = @article_ids[3]
    body = {:articlesToAdd=>[article1,article2,article3]}.to_json
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
    articles.should include article1.to_s
    articles.should include article2.to_s
    articles.should include article3.to_s

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

    articles.should include article1.to_s
    articles.should include article2.to_s
    articles.should include article3.to_s

    articles.index(article1.to_s).should < articles.index(article2.to_s)
    articles.index(article2.to_s).should < articles.index(article3.to_s)
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
    tiles.should_not include article1.to_s
    tiles.should_not include article2.to_s

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
    tiles.should_not include article1.to_s
    tiles.should_not include article2.to_s
  end

  it 'should add more articles and order them by newest added first' do
    id = CollectionFlowHelper.collection['id'] 
    # Add the 8th article
    article8 = @article_ids[7]
    body = {:articlesToAdd=>[article8]}.to_json
    url = @bifrost_env+"/collections/#{id}/config?api_key="+@session
    begin
      response = RestClient.put url, body, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end

    # Add the 6th article
    article6 = @article_ids[5]
    body = {:articlesToAdd=>[article6]}.to_json
    url = @bifrost_env+"/collections/#{id}/config?api_key="+@session
    begin
      response = RestClient.put url, body, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end

    # Assert ordered by newest added first
    order = [5,7,3,0]
    url = @bifrost_env+"/collections/#{id}?api_key="+@session
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    articles = []
    i = 0
    data['tiles'].each do |tile|
      unless tile['tileType'] == 'interest'
        tile['contentId'].should == @article_ids[order[i]].to_s
        i = i+1
      end
    end
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
    interests.should include interest1
    interests.should include interest2

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
    interests.should include interest1
    interests.should include interest2
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
    interests.should_not include interest1
    interests.should_not include interest2

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
    interests.should_not include interest1
    interests.should_not include interest2
  end

  it 'should add more interests and order them by newest added first' do
    id = CollectionFlowHelper.collection['id']
    order = [@interest_four, @interest_three, @interest_one, @interest_two]
    body = {:pinnedInterestsToAdd=>[@interest_three]}.to_json
    url = @bifrost_env+"/collections/#{id}/config?api_key="+@session
    begin
      response = RestClient.put url, body, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    body = {:pinnedInterestsToAdd=>[@interest_four]}.to_json
    url = @bifrost_env+"/collections/#{id}/config?api_key="+@session
    begin
      response = RestClient.put url, body, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    url = @bifrost_env+"/collections/#{id}?api_key="+@session
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    i = 0
    data['tiles'].each do |tile|
      unless tile['tileType'] == 'article'
        tile['contentId'].should == order[i]
        i = i+1
      end
    end
  end

  it 'should not clump all interest or article tiles together' do
    id = CollectionFlowHelper.collection['id']
    url = @bifrost_env+"/collections/#{id}?api_key="+@session
    tileTypes = []
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    data['tiles'].each do |tile|
      tileTypes << tile['tileType']
    end
    tileTypes.length.should > 3
    tileTypes.should_not == tileTypes.sort
    tileTypes.should_not == tileTypes.sort { |x,y| y <=> x } 
  end

  it 'should return true when asked if a colleciton with this name exists before name change' do
    collection_name = @collection_name
    url = @bifrost_env+"/collections/exists?name=#{collection_name}&api_key="+@session
    begin 
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    data['exists'].to_s.should == 'true'
  end

  it 'should both add and remove items in a single put' do
    # add concept Apple
    # del concept Knitting
    # add article @article_ids[6]
    # del article @article_ids[5]

    id = CollectionFlowHelper.collection['id']
    body = {"articlesToRemove"=>[@article_ids[5]],"pinnedInterestsToRemove"=>['Knitting'],
            "articlesToAdd"=>[@article_ids[6]],"pinnedInterestsToAdd"=>['Apple'],"enableRecommendations"=>true}.to_json
    url = @bifrost_env+"/collections/#{id}/config?api_key="+@session
    begin
      response = RestClient.put url, body, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response

    content_ids = []
    data['tiles'].each do |tile|
      content_ids << tile['contentId']
    end

    content_ids.should include 'Apple'
    content_ids.should include @article_ids[6].to_s
    content_ids.should_not include 'Knitting'
    content_ids.should_not include @article_ids[5].to_s

    # Now do a get and make same assertions
    url = @bifrost_env+"/collections/#{id}?api_key="+@session
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end

    data = JSON.parse response
    content_ids = []
    data['tiles'].each do |tile|
      content_ids << tile['contentId']
    end

    content_ids.should include 'Apple'
    content_ids.should include @article_ids[6].to_s
    content_ids.should_not include 'Knitting'
    content_ids.should_not include @article_ids[5].to_s
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

  it "should add an 'recommendations-disabled' flag" do
    id = CollectionFlowHelper.collection['id']
    body = {:enableRecommendations=>false}.to_json
    url = @bifrost_env+"/collections/#{id}/config?api_key="+@session
    begin
      response = RestClient.put url, body, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end

    url = @bifrost_env+"/collections/#{id}?api_key="+@session
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    data['flags'].should include 'recommendations-disabled'
  end

  it "should remove the 'recommendations-disabled' flag" do
    id = CollectionFlowHelper.collection['id']
    body = {:enableRecommendations=>true}.to_json
    url = @bifrost_env+"/collections/#{id}/config?api_key="+@session
    begin
      response = RestClient.put url, body, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end

    url = @bifrost_env+"/collections/#{id}?api_key="+@session
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    data['flags'].should_not include 'recommendations-disabled'
  end

  it 'should prevent others from adding an article to a collection you created' do
    id = CollectionFlowHelper.collection['id']
    article = @article_ids[9]
    body = {:articlesToAdd=>[article]}.to_json
    url = @bifrost_env+"/collections/#{id}/config?api_key="+@anon_session
    expect {RestClient.put url, body, @headers}.to raise_error(RestClient::ResourceNotFound)

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
    articles.should_not include article.to_s
  end

  it 'should return true when asked if a colleciton with this name exists after name change' do
    collection_name = 'modified%20name'
    url = @bifrost_env+"/collections/exists?name=#{collection_name}&api_key="+@session
    begin 
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    data['exists'].to_s.should == 'true'
  end

  it 'should return false when asked if a colleciton with a fake name exists' do
    collection_name = 'sjsdfohsjfohsdfhqw'
    url = @bifrost_env+"/collections/exists?name=#{collection_name}&api_key="+@session
    begin 
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    data['exists'].to_s.should == 'false'
  end

  it 'should return false when asked if a existing collcection name that is not yours exists' do
    collection_name = 'modified%20name'
    url = @bifrost_env+"/collections/exists?name=#{collection_name}&api_key="+@anon_session
    begin 
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    data['exists'].to_s.should == 'false'
  end

  it 'should not allow another user to delete your collection' do
    collection_id = CollectionFlowHelper.collection['id']
    url = @bifrost_env+"/collections/#{collection_id}?api_key="+@anon_session
    expect {RestClient.delete url, @headers}.to raise_error(RestClient::ResourceNotFound)
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

  it "should allow create a collection with a nil summary" do
    url = @bifrost_env+"/collections?api_key="+@session
    body = {
              :collection_name=>@collection_name+'nil_summary',
              :articles=>[@article_ids[0]],
              :pinnedConcepts=>[
                @interest_one
              ],
              :summary=>nil
            }.to_json
    begin 
      response = RestClient.post url, body, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    id = (JSON.parse response)['id']
    id.to_s.length.should > 0
    sleep 1
    url = @bifrost_env+"/collections/#{id}?api_key="+@session
    begin 
      response = RestClient.delete url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
  end
end
