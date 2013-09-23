require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'

%w(/collections /collections/123 /collections/shared/123/123 
  /collections/123/recommendations?limit=20&skip=0).each do |endpoint|
  describe "COLLECTIONS API -- GET #{endpoint} when bad auth key" do

    before(:all) do
      ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
      @config = ConfigPath.new
      @url_no_key = "https://#{@config.options['baseurl']}#{endpoint}"
      if endpoint.match(/\?/)
        @url_invalid_key = "https://#{@config.options['baseurl']}#{endpoint}&api_key=123"
      else
        @url_invalid_key = "https://#{@config.options['baseurl']}#{endpoint}?api_key=123"
      end
        
    end

    before(:each) do

    end

    after(:each) do

    end

    it "should 401 when no auth key" do
      expect {RestClient.get @url_no_key}.to raise_error(RestClient::Unauthorized)
    end
  
    it "should 401 when invalid auth key" do
      expect {RestClient.get @url_invalid_key}.to raise_error(RestClient::Unauthorized)
    end
  end
end

