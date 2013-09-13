require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'

%w(interests tiles).each do |endpoint|
  %w(me me?skip=0&limit=20 social global).each do |context|
    describe "Trending API -- GET /trending/#{endpoint}/#{context} with bad auth key" do

      before(:all) do
        ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
        @config = ConfigPath.new
        @url_no_key = "https://#{@config.options['baseurl']}/trending/interests/#{context}"
        if endpoint.match(/\?/)
          @url_invalid_key = "https://#{@config.options['baseurl']}/trending/#{endpoint}/#{context}&api_key=123"
        else
          @url_invalid_key = "https://#{@config.options['baseurl']}/trending/#{endpoint}/#{context}?api_key=123"
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
end