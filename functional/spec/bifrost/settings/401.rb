require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'

describe "SETTINGS - GET /settings/homescreen with bad auth key" do

  before(:all) do
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @config = ConfigPath.new
    @url_no_key = "https://#{@config.options['baseurl']}/settings/homescreen"
    @url_invalid_key = "https://#{@config.options['baseurl']}/settings/homescreen?api_key=123"
  end

  it "should 401 when no auth key" do
    expect {RestClient.get @url_no_key}.to raise_error(RestClient::Unauthorized)
  end
  
  it "should 401 when invalid auth key" do
    expect {RestClient.get @url_invalid_key}.to raise_error(RestClient::Unauthorized)
  end
end
