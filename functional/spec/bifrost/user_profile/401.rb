require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'

%w(/userProfile/activityStream /userProfile/byUserId/123 /userProfile/followers /userProfile/following 
  /userProfile/history /userProfile/history/first /userProfile/mine /userProfile/reverbs).each do |endpoint|
  describe "USER PROFILE API - GET #{endpoint} with bad auth key" do

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
  
    it "should 401 when no invalid key" do
      expect {RestClient.get @url_invalid_key}.to raise_error(RestClient::Unauthorized)
    end
  end
end
