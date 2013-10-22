require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'colorize'

include Token

describe "USER FLOWS - Add Interest to Anon User" do

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_anon_token(@bifrost_env)

    # Interest to Add
    @interest = 'Cake'
  end

  it 'should add an interest' do
    # add interest
    url = @bifrost_env+"/interests?api_key="+@session_token
    begin
      response = RestClient.post url, {:value=>@interest,:interestType=>:interest}.to_json, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    
    # check interest added to me wall
    url = @bifrost_env+"/trending/interests/me?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse response
    me_wall = []
    data['interests'].each do |interest|
      me_wall << interest['value']
    end
    begin
      me_wall.include?(@interest).should be_true
    rescue
      puts me_wall
      puts ""
      puts url
    end
  end
end