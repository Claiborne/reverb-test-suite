require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'api_checker.rb'

include APIChecker

describe "INTERESTS - Interest Search", :strict => true do

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session = get_anon_token(@bifrost_env)

    @interest = 'Cake'

    url = @bifrost_env+"/interests/search/#@interest?limit=10&api_key="+@session
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    @data = JSON.parse response
  end

  it 'should return 10 interests' do
    @data['results'].length.should == 10
  end

 %w(value size resultType).each do |field|
    it "should return a non-nil, non-blank #{field} value for each result" do
      @data['results'].each do |result|
        check_not_nil result[field]
        check_not_blank result[field]
      end
    end
  end

  it 'should return a size value of greater than 0 for each result' do
    @data['results'].each do |result|
      result['size'].should > 0
    end
  end

  it "should return a resultType value of 'interest' for each result" do
    @data['results'].each do |result|
      result['resultType'].should == 'interest'
    end
  end

  it 'should return an image for each result' do
    @data['results'].each  do |result|
      check_not_nil result['contentImage']['url']
      check_not_blank result['contentImage']['url']
    end
  end

  it 'should return at least one non-broken image for all results' do
    @data['results'].each do |result|
      success = false
      url = result['contentImage']['url']+"?api_key=#@session"
      begin
        response = RestClient.get url
        success = true
        break
      rescue => e
        next
      end
      success.should == true
    end
  end
end
