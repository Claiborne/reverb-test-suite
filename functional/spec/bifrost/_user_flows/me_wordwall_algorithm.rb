require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'; include Token
require 'bifrost/app_actions.rb'; include AppActions

describe "USER FLOWS - Me Wordwall Algorithm", :me_wordwall_ranking => true, :strict => true do

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_anon_token @bifrost_env
    @interest_one = 'Apple'
    @interest_two = 'Toast'

    case ENV['env']
    when 'prd'
      @cake_articles = ['66582474','66653851','66555978','66608386','66672048']
      @rose_articles = ['66561888', '66636756', '66664974', '66685731', '68524563']
    when 'stg'
      @cake_articles = ['43927335','43872413','43872454','43901305','43906389']
      @rose_articles = ['43925386', '43901483', '43916689', '43908347', '43901483']
    when 'dev'
      raise StandardError, 'DEV is currently not supported for this test group'
    else
      raise StandardError, 'No compatable env for this test group'
    end
  end

  it 'should add Apple to the me the top of the me wordwall' do
    iphone_add_interest(@bifrost_env, @session_token, @interest_one)
    url = @bifrost_env+"/trending/interests/me?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    first_me_interest = (JSON.parse response)['interests'][0]['value']
    first_me_interest.should == @interest_one
  end

  it 'should add Toast to the me the top of the me wordwall' do
    iphone_add_interest(@bifrost_env, @session_token, @interest_two)
    sleep 2
    url = @bifrost_env+"/trending/interests/me?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    first_me_interest = (JSON.parse response)['interests'][0]['value']
    first_me_interest.should == @interest_two
  end

  it 'should tap Apple and cause it to go to the top of the me wordwall' do
    iphone_tap_interest @bifrost_env, @session_token, @interest_one
    sleep 2
    url = @bifrost_env+"/trending/interests/me?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    first_me_interest = (JSON.parse response)['interests'][0]['value']
    first_me_interest.should == @interest_one
  end

  it 'should read five articles about Cake and cause Cake to go to the top of the me wordwall' do
    @cake_articles.each do |cake_article|
      ipad_read_article @bifrost_env, @session_token, cake_article
    end
    url = @bifrost_env+"/trending/interests/me?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    first_me_interest = (JSON.parse response)['interests'][0]['value']
    first_me_interest.should == 'Cake'
  end

  it 'should read five articles about Rose and cause Rose to go to the top of the me wordwall' do
    @rose_articles.each do |rose_article|
      ipad_read_article @bifrost_env, @session_token, rose_article
    end
    url = @bifrost_env+"/trending/interests/me?api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    first_me_interest = (JSON.parse response)['interests'][0]['value']
    first_me_interest.should == 'Rose'
  end
end
