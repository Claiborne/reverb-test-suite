require 'json'
require 'rest_client'

describe "USER FLOWS - View Topic and Interests and Personalize" do
  
  def tap_interest(time, interest)
    {
    "events"=> [
      {
      "eventType"=> "uTapInterest",
      "location"=> {
      "lat"=>'37.55',
      "lon"=>'122.31'
      },
      "eventArgs"=> [
      {
      "name"=> "interestName",
      "value"=>interest
      },
      {
      "name"=>"tappedFromApp",
      "value"=>'1'
      },
      {
      "name"=>"tappedFromType",
      "value"=>'1'
      },
      {
      "name"=>"rank",
      "value"=>'5'
      },
      {
      "name"=>"featured",
      "value"=>'0'
      },
      {
      "name"=>"view",
      "value"=>'1'
      }
      ],
      "startTime"=>(time*1000)
      }
    ]
    }.to_json
  end

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

    @topic = 'Sports'
    @interest = 'Cake'
  end

  it 'should get a topic' do
    url = "#{@bifrost_env}/interests/stream/me?interest=#@topic&skip=0&limit=24&api_key=#{@session}"
    begin
      res = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse res
    data['tiles'].length.should > 0
  end

  it 'should send a tap interest event' do
    RestClient.post @event_url, tap_interest(Time.now.utc.to_i-30, @topic), 'Content-Type' => 'application/json'
  end

  it "should update user's history" do
    sleep 1
    url = "#@bifrost_env/userProfile/history?startDate=1970-01-01T00:00:00.000Z&endDate=2015-10-30T22:18:13.410Z&skip=0&limit=24&api_key=#@session"
    res = RestClient.get url, @headers
    data = JSON.parse res
    data['tiles'].count.should > 0
    history_tiles = []
    data['tiles'].each do |tile|
      history_tiles << tile['contentId'].to_s
    end
    history_tiles.include?(@topic).should be_true
  end

  it 'should get a topic' do
    url = "#{@bifrost_env}/interests/stream/me?interest=#@interest&skip=0&limit=24&api_key=#{@session}"
    begin
      res = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse res
    data['tiles'].length.should > 0
  end

  it 'should send a tap interest event' do
    RestClient.post @event_url, tap_interest(Time.now.utc.to_i-30, @interest), 'Content-Type' => 'application/json'
  end

  it "should update user's history" do
    sleep 1
    url = "#@bifrost_env/userProfile/history?startDate=1970-01-01T00:00:00.000Z&endDate=2015-10-30T22:18:13.410Z&skip=0&limit=24&api_key=#@session"
    res = RestClient.get url, @headers
    data = JSON.parse res
    data['tiles'].count.should > 0
    history_tiles = []
    data['tiles'].each do |tile|
      history_tiles << tile['contentId'].to_s
    end
    history_tiles.include?(@interest).should be_true
  end
end
