require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'api_checker.rb'; include APIChecker

describe "CHIRP - Get Chirp and Auth", :stg => true do

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    headers = {:content_type => 'application/json', :accept => 'application/json'}

    clientId = get_client_id
    clientSecret = get_client_secret

    body = {
      :deviceId => 'reverb-test-suite',
      :agent => {
        :timeZone => '-07:00',
        :appVersion => {:major => 2, :patch => 0, :minor => 1}
      }
    }.to_json

    url = bifrost_env+"/account/chirpWithAuthSession?clientSecret=#{clientSecret}&clientId=#{clientId}"
    begin
      response = RestClient.post url, body, headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    @data = (JSON.parse response)['success']
  end

  context "AuthSession" do

    %w(userId token login email settings).each do |key|
      it "should return a non-blank, non-nil authSession.#{key} value" do
        @data['authSession'][key].should be_true
        check_not_blank @data['authSession'][key]
        check_not_nil @data['authSession'][key]
      end
    end

    it 'should return a valid authSession.profilePicture.url that returns a 200' do
      @data['authSession']['profilePicture']['url'].should be_true
      check_not_blank @data['authSession']['profilePicture']['url']
      check_not_nil @data['authSession']['profilePicture']['url']
      RestClient.get @data['authSession']['profilePicture']['url']
    end

    it 'should return authSession.flag with a value of unconfirmed-email' do
      @data['authSession']['flags'].include?('unconfirmed-email').should be_true
    end

    it 'should return authSession.flag with a value of anonymous' do
      @data['authSession']['flags'].include?('anonymous').should be_true
    end
  end

  context "Chip" do

    it "should return a non-blank, non-nil chirp.apiBasePath value" do
      @data['chirp']['apiBasePath'].should be_true
      check_not_blank @data['chirp']['apiBasePath']
      check_not_nil @data['chirp']['apiBasePath']
    end

    it "should return an iPad homescreen image for portrait and landscape that returns a 200" do
      portrait_background = @data['chirp']['settings']['homeImages'][0]['portraitUrl']
      landscape_background = @data['chirp']['settings']['homeImages'][0]['landscapeUrl']
      check_not_blank portrait_background
      check_not_nil portrait_background
      check_not_blank landscape_background
      check_not_nil landscape_background
      RestClient.get portrait_background
      RestClient.get landscape_background
    end

    it "should return at least 4 wordwall colors for the iPad" do
      @data['chirp']['settings']['homeImages'][0]['wordColors'].length.should > 3
      @data['chirp']['settings']['homeImages'][0]['wordColors'].each do |color|
        color.to_s.match(/red\"=>[0-9]{1,}/).should be_true
        color.to_s.match(/green\"=>[0-9]{1,}/).should be_true
        color.to_s.match(/blue\"=>[0-9]{1,}/).should be_true
      end
    end

    it "should return an iPhone homescreen image for portrait and landscape that returns a 200" do
      portrait_background = @data['chirp']['settings']['phoneHomeImages'][0]['portraitUrl']
      landscape_background = @data['chirp']['settings']['phoneHomeImages'][0]['landscapeUrl']
      check_not_blank portrait_background
      check_not_nil portrait_background
      check_not_blank landscape_background
      check_not_nil landscape_background
      RestClient.get portrait_background
      RestClient.get landscape_background
    end

    it "should return at least 4 wordwall colors for the iPhone" do
      @data['chirp']['settings']['phoneHomeImages'][0]['wordColors'].length.should > 3
      @data['chirp']['settings']['phoneHomeImages'][0]['wordColors'].each do |color|
        color.to_s.match(/red\"=>[0-9]{1,}/).should be_true
        color.to_s.match(/green\"=>[0-9]{1,}/).should be_true
        color.to_s.match(/blue\"=>[0-9]{1,}/).should be_true
      end
    end
  end
end

describe "CHIRP - Get Chirp only", :stg => true do

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    headers = {:content_type => 'application/json', :accept => 'application/json'}

    token = get_anon_token bifrost_env

    body = {
      :appVersion => {:major => 2, :patch => 0, :minor => 1},
      :timeZone => '-07:00'
    }.to_json

    url = bifrost_env+"/settings/chirp?api_key=#{token}"
    begin
      response = RestClient.post url, body, headers
    rescue => e
      raise StandardError.new(e.message+" "+url)
    end
    @data = (JSON.parse response)['success']
  end

  it "should return a non-blank, non-nil apiBasePath value" do
    @data['apiBasePath'].should be_true
    check_not_blank @data['apiBasePath']
    check_not_nil @data['apiBasePath']
  end

  it "should return an iPad homescreen image for portrait and landscape that returns a 200" do
    portrait_background = @data['settings']['homeImages'][0]['portraitUrl']
    landscape_background = @data['settings']['homeImages'][0]['landscapeUrl']
    check_not_blank portrait_background
    check_not_nil portrait_background
    check_not_blank landscape_background
    check_not_nil landscape_background
    RestClient.get portrait_background
    RestClient.get landscape_background
  end

  it "should return at least 4 wordwall colors for the iPad" do
    @data['settings']['homeImages'][0]['wordColors'].length.should > 3
    @data['settings']['homeImages'][0]['wordColors'].each do |color|
      color.to_s.match(/red\"=>[0-9]{1,}/).should be_true
      color.to_s.match(/green\"=>[0-9]{1,}/).should be_true
      color.to_s.match(/blue\"=>[0-9]{1,}/).should be_true
    end
  end

  it "should return an iPhone homescreen image for portrait and landscape that returns a 200" do
    portrait_background = @data['settings']['phoneHomeImages'][0]['portraitUrl']
    landscape_background = @data['settings']['phoneHomeImages'][0]['landscapeUrl']
    check_not_blank portrait_background
    check_not_nil portrait_background
    check_not_blank landscape_background
    check_not_nil landscape_background
    RestClient.get portrait_background
    RestClient.get landscape_background
  end

  it "should return at least 4 wordwall colors for the iPhone" do
    @data['settings']['phoneHomeImages'][0]['wordColors'].length.should > 3
    @data['settings']['phoneHomeImages'][0]['wordColors'].each do |color|
      color.to_s.match(/red\"=>[0-9]{1,}/).should be_true
      color.to_s.match(/green\"=>[0-9]{1,}/).should be_true
      color.to_s.match(/blue\"=>[0-9]{1,}/).should be_true
    end
  end
end
  