require 'rspec'
#require 'config_path'
require 'rest_client'
#require 'json'

  describe "IMAGE API - GET Article Tile Image" do

    before(:all) do
      # Get bifrost environment
      ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/images.yml"
      @image_env = "https://#{ConfigPath.new.options['baseurl']}"

      # Set headers
      @headers = {:content_type => 'application/json', :accept => 'application/json'}

      # Get anon session token
      @session_token = get_anon_token(@bifrost_env)

      @prd_article = 53671175
      @stg_article = 43499877
      @prd_article = 53671175
    end

    it 'should return a 200' do
      url = @image_env+"/interests/search/#{interest}?limit=10&api_key="+@session_token
      begin
        response = RestClient.get url, @headers
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
    end

end
