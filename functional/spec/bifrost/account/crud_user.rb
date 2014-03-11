require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'

describe "ACCOUNT API - CRUD User", :crud => true, :test => true do

  class AccountFlowHelper
    class << self; attr_accessor :user_id, :user_token; end
  end

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"
    @headers = {:content_type => 'application/json', :accept => 'application/json'}
    @login = 'rvb'+(Random.rand 10000000000).to_s
    @anon_token = get_anon_token @bifrost_env
  end

  it 'should correctly create a new user' do
    url = @bifrost_env+"/account/register?clientId="+get_client_id
    body = {
      :login => @login,
      :password => 'testpassword',
      :passwordConfirmation => 'testpassword',
      :email => "#@login@reverbtest.com",
      :name => @login,
      :deviceId => 'reverb-test-suite'
    }.to_json
    begin 
      response = RestClient.post url, body, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response 
    AccountFlowHelper.user_id = data['userId']
    data['login'].should == @login
    data['name'].should == @login
    data['email'].should == "#@login@reverbtest.com"
    data['token'].length.should > 5
    data['profilePicture']['url'].match(/http/).should be_true
  end

  it 'should sign in the newly created user' do
    sleep 3
    AccountFlowHelper.user_token = get_token(@bifrost_env, @login, "testpassword")
  end

  it 'should get the newly created user by ID' do
    id = AccountFlowHelper.user_id
    token = AccountFlowHelper.user_token
    url = @bifrost_env+"/userProfile/byUserId/#{id}?api_key=#{token}"
    begin 
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    data['userId'].should == id
    data['login'].should == @login
    data['name'].should == @login
    data['email'].should == "#@login@reverbtest.com"
    data['profilePicture']['url'].match(/http/).should be_true
  end

  it "should moodify the user's bio" do
    token = AccountFlowHelper.user_token
    id = AccountFlowHelper.user_id
    bio = "updated #{Random.rand 1000000}"
    body = {:bio=>bio}.to_json

    # update profile
    url = @bifrost_env+"/userProfile/bio?api_key=#{token}"
    begin 
      response = RestClient.post url, body, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end

    # check profile updated   
    sleep 1
    url = @bifrost_env+"/userProfile/byUserId/#{id}?api_key=#{token}"
    begin 
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    data = JSON.parse response
    data['bio'].should == bio
  end

  it 'should delete the user' do
    url = @bifrost_env+"/account?api_key=#{AccountFlowHelper.user_token}"
    begin
      RestClient.delete url, @headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
  end

  it 'should return a 401 when requesting deleted user by ID' do
    id = AccountFlowHelper.user_id
    token = AccountFlowHelper.user_token
    url = @bifrost_env+"/userProfile/byUserId/#{id}?api_key=#{token}"
    expect {RestClient.get url, @headers}.to raise_error(RestClient::Unauthorized)
  end

  it 'should return a 401 when attempting to login deleted user' do
    begin
      get_token(@bifrost_env, @login, "testpassword")
    rescue => e
      e.to_s.match(/401 Unauthorized/).should be_true
    end
  end

end