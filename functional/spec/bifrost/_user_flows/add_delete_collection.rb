require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'api_checker.rb'

include APIChecker

describe "USER FLOWS - Create and Delete Collections", :collections => true, :stg => true do

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

    @collection_name = "claytest#{Random.rand 1000000000}"

    if ENV['env'] == 'dev'
      @collection_article_id = 2694320
    elsif ENV['env'] == 'stg'
      @collection_article_id = 42983919
    elsif ENV['env'] == 'prd'
      @collection_article_id = 47702591
    else
      @collection_article_id = 2694320 # default to stage
    end

  end

  it "should create a collection" do
    url = @bifrost_env+"/collections?api_key="+@session
    body = {
              "collection_name"=>@collection_name,
              "articles"=>[@collection_article_id],
              "pinnedConcepts"=>[
                "Knitting", "Cake"
              ],
              "summary"=>"this is the summary"
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
    CollectionFlowHelper.collection['tiles'][0]['contentId'].should == @collection_article_id.to_s
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
