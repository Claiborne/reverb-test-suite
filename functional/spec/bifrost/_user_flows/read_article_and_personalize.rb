require 'json'
require 'rest_client'
require 'thread'
require 'bifrost/read_article.rb'

describe "USER FLOWS - Read an Article and Personalize", :read_article => true, :strict => true do

  include ReadArticle

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session = get_anon_token(@bifrost_env)

    # Click stream URL
    @event_url = "#{@bifrost_env}/events/click?deviceId=reverb-test-suite&api_key=#{@session}"

    # Define env data
    case ENV['env']
    when 'prd'
      @article_data = {:article_id => '66297889', :concepts => ["Miami", "Coincidence", "Wisconsin", "Twitter", "National Football League Draft"]}
    when 'stg'
      @article_data = {:article_id => '38515770', :concepts => ["California", "West Sacramento, California", "Oakland Raiders", "Letter box", "National Football League", "Showdown (poker)"]}
    when 'dev'
      @article_data = {:article_id => '1888584', :concepts => ["San Francisco", "Kansas City, Missouri"]}
    else
      raise StandardError, 'No compatable env for this test group'
    end

  end

  it 'should get an article' do
    url = "#{@bifrost_env}/articles/docId/#{@article_data[:article_id]}?api_key=#{@session}"
    res = RestClient.get url, @headers
    data = JSON.parse res
    data['docId'].to_i.should == @article_data[:article_id].to_i
  end

  it 'should send an article read event' do
    RestClient.post @event_url, read_article(Time.now.utc.to_i-30, @article_data[:article_id]), 'Content-Type' => 'application/json'
  end

  it 'should exit an article after 5 seconds' do
    sleep 5
    RestClient.post @event_url, exit_article(Time.now.utc.to_i-30), 'Content-Type' => 'application/json' 
  end

  it 'should update me wordwall' do
    sleep 3
    url = "#{@bifrost_env}/trending/interests/me?api_key=#{@session}"
    res = RestClient.get url, @headers
    data = JSON.parse res

    trending_me_interests = []
    data['interests'].each do |interest|
      trending_me_interests << interest['value']
    end
    trending_me_interests.length.should > 0

    @article_data[:concepts].each do |article_concept|
      trending_me_interests.include?(article_concept).should be_true
    end
  end

  it 'should update user history' do
    sleep 10
    url = "#@bifrost_env/userProfile/history?startDate=1970-01-01T00:00:00Z&endDate=2015-10-30T22:18:13Z&skip=0&limit=24&api_key=#@session"
    res = RestClient.get url, @headers
    data = JSON.parse res
    data['tiles'].count.should > 0
    history_tiles = []
    data['tiles'].each do |tile|
      history_tiles << tile['contentId'].to_s
    end
    history_tiles.include?(@article_data[:article_id]).should be_true
  end

  it 'should delete an inferred interest' do
    interest = @article_data[:concepts][0]
    url = "#@bifrost_env/interests?interest=#{CGI::escape interest}&api_key=#@session"
    RestClient.delete url, @headers
  end

  it "should remove inferred interest from user's wordwall" do
    url = "#{@bifrost_env}/trending/interests/me?api_key=#{@session}"
    res = RestClient.get url, @headers
    data = JSON.parse res

    trending_me_interests = []
    data['interests'].each do |interest|
      trending_me_interests << interest['value']
    end
   trending_me_interests.length.should > 0
   trending_me_interests.include?(@article_data[:concepts][0].to_s).should be_false
  end
end
