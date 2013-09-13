require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'

describe "Trending API -- GET /trending/interests/me without auth key" do

  before(:all) do
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @config = ConfigPath.new
    @url = "https://#{@config.options['baseurl']}/trending/interests/me"
  end

  it "should 401" do
    expect {RestClient.get @url}.to raise_error(RestClient::Unauthorized)
  end
end

describe "Trending API -- GET /trending/interests/me invalid auth key" do

  before(:all) do
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @config = ConfigPath.new
    @url = "https://#{@config.options['baseurl']}/trending/interests/me?api_key=123"
  end

  it "should 401" do
    expect {RestClient.get @url}.to raise_error(RestClient::Unauthorized)
  end
end
