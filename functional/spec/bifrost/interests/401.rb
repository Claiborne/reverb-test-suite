require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'

%w(/interests/search/love?limit=10 /interests/stream/me?interest=love&skip=0&limit=20).each do |endpoint|
  describe "INTERESTS - GET #{endpoint} with bad auth key", :test => true do

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

    it "should 401 when no auth key (FAILS IN PRODUCTION RVB-6676)", :fails => true do
      expect {RestClient.get @url_no_key}.to raise_error(RestClient::Unauthorized)
    end
  
    it "should 401 when invalid auth key (FAILS IN PRODUCTION RVB-6676)", :fails => true do
      expect {RestClient.get @url_invalid_key}.to raise_error(RestClient::Unauthorized)
    end
  end
end
