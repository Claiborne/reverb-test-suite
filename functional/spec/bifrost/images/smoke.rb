require 'rspec'
require 'config_path'
require 'rest_client'

describe "IMAGES - GET Article Tile Image" do

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Get image environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/images.yml"
    @image_env = "http://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_anon_token(@bifrost_env)

    case ENV['env']
    when 'prd'
      @article = 53671175
    when 'stg'
      @article = 43499877
    when 'dev'
      @article = 53671175
    when 'basil'
      @article = 9452
    when 'anise'
      @article = 22034
    when 'thyme'
      @article = 100023
    when 'nutmeg'
      @article = 3037
    else
      raise RuntimeError, 'No suitable env to run this spec (dev, stg, or prd)'
    end
  end

  it 'should return a 200' do
    url = @image_env+"/api/image/article/#@article?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    response.code.should == 200
  end
end
