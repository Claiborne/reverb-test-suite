require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'

describe "Wordnik API -- GET /wordnik/love/definitions?limit=10 without auth key" do

  before(:all) do
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @config = ConfigPath.new
    @url = "https://#{@config.options['baseurl']}/wordnik/love/definitions?limit=10"
  end

  it "should 401" do
    expect {RestClient.get @url}.to raise_error(RestClient::Unauthorized)
  end
end

describe "Wordnik API -- GET /wordnik/love/definitions?limit=10 invalid auth key" do

  before(:all) do
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @config = ConfigPath.new
    @url = "https://#{@config.options['baseurl']}/wordnik/love/definitions?limit=10&api_key=123"
  end

  it "should 401" do
    expect {RestClient.get @url}.to raise_error(RestClient::Unauthorized)
  end
end
