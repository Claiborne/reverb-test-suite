require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'

%w(/articles/articlesByLocation?lon=1&lat=1&lonDelta=1&latDelta=1&nearestLimit=1&popularLimit=1 /articles/docId/123 /articles/recommendations/123?skip=0&limit=20).each do |endpoint|
  describe "Articles API -- GET #{endpoint} with bad auth key" do

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

    it "should 401 when no auth key" do
      expect {RestClient.get @url_no_key}.to raise_error(RestClient::Unauthorized)
    end
  
    it "should 401 when invalid auth key" do
      expect {RestClient.get @url_invalid_key}.to raise_error(RestClient::Unauthorized)
    end
  end
end
