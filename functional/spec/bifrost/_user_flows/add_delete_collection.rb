require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'api_checker.rb'

include APIChecker

describe "USER FLOWS - Create and Delete Collections", :test => true do

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

  end

  it "should create a collection" do
    url = @bifrost_env+"/collections?api_key="+@session
    body = {
              "collection_name"=>@collection_name,
              "articles"=>[
                "2"
              ],
              "pinnedConcepts"=>[
                "Knitting", "Cake"
              ],
              "summary"=>"this is the summary"
            }
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

  it 'should create a collection with the appropriate article count' do
    CollectionFlowHelper.collection['tiles'][0]['count']['items'].should == 2
  end

  it 'should create a collection with the appropriate pinnedConcepts' do
    pinned_concepts = ["Knitting", "Cake"]
    CollectionFlowHelper.collection['contentPreferences']['pinnedConcepts'].should == pinned_concepts
  end

  it 'should create a collection with the appropriate summary' do
    CollectionFlowHelper.collection['summary'].should == 'this is the summary'
  end

end
