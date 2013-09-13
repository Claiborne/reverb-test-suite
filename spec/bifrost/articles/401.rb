require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'

describe "Articles API -- GET /articles/docId/123 without auth key" do

  before(:all) do
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @config = ConfigPath.new
    @url = "https://#{@config.options['baseurl']}/articles/docId/123"
  end

  it "should 401" do
    expect {RestClient.get @url}.to raise_error(RestClient::Unauthorized)
  end
end

describe "Articles API -- GET /articles/docId/123 invalid auth key" do

  before(:all) do
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @config = ConfigPath.new
    @url = "https://#{@config.options['baseurl']}/articles/docId/123?api_key=123"
  end

  before(:each) do

  end

  after(:each) do

  end

  it "should 401" do
    expect {RestClient.get @url}.to raise_error(RestClient::Unauthorized)
  end
end