require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'; include Token

describe "USER FLOWS - Social Wall", :test => true do

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_token @bifrost_env, 'clay_social', 'testpassword'
  end

  it 'should start with a blank social wall' do
    url = "#@bifrost_env/trending/interests/social?skip=0&api_key=#@session_token"
    begin
      res = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse res
    data['interests'].length.should == 0
  end

  it 'should start with blank social tiles' do
    url = "#@bifrost_env/trending/tiles/social?skip=0&api_key=#@session_token"
    begin
      res = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse res
    data['tiles'].length.should == 0
  end

  it 'should post a share event to baldr' do

  end

  it 'should have content on user\'s social wall after baldr share' do

  end

  it 'should have content on user\'s social tiles after baldr share' do

  end

  it 'should have contnent for each social word after baldr share' do

  end
end