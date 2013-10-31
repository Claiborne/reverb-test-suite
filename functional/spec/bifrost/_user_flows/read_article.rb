
require 'json'
require 'rest_client'
require 'thread'

describe "USER FLOWS - Read an Article and Update Me Wordwall" do

  def read_article(time, article)
    {
    "events"=> [
      {
      "eventType"=> "uTapArticle",
      "location"=> {
      "lat"=>'37.55',
      "lon"=>'122.31'
      },
      "eventArgs"=> [
      {
      "name"=> "docId",
      "value"=> article
      },
      {
      "name"=>"tappedFromApp",
      "value"=>'7'
      },
      {
      "name"=>"tappedFromType",
      "value"=>'3'
      },
      {
      "name"=>"rank",
      "value"=>'1'
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
      "startTime"=>time
      }
    ]
    }.to_json
  end

  def exit_article(time)
    {
      "events"=> [
        {
        "eventType"=> "uTapHome",
        "location"=> {
        "lat"=> '37.55',
        "lon"=> '122.31'
        },
        "eventArgs"=> [
        {
          "name"=> "tappedFromType",
          "value"=>'1'
        },
        {
         "name"=>"tappedFromApp",
          "value"=>'11'
        },
        {
          "name"=> "currentHomescreen",
          "value"=>'1'
        }
        ],
        "startTime"=>time
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
    @event_url = "#{@bifrost_env}/events/click?deviceId=load-test&api_key=#{@session}"

    # Define env data
    case ENV['env']
    when 'prd'
      @article_data = {:article_id => '42419084', :concepts => ["San Francisco", "Brandon Jacobs", "Adam Schefter", "Getty Images", "NFC Championship Game", "ESPN"]}
    when 'stg'
      @article_data = {:article_id => '38515770', :concepts => ["California", "San Francisco 49ers", "West Sacramento", "Oakland Raiders", "Letter box", "National Football League", "Showdown (poker)"]}
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
    RestClient.post @event_url, read_article(Time.now.to_i, @article_data[:article_id]), 'Content-Type' => 'application/json'
  end

  it 'should exit an article after 15 seconds' do
    sleep 15
    RestClient.post @event_url, exit_article(Time.now.to_i), 'Content-Type' => 'application/json' 
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

    @article_data[:concepts].each do |article_concept|
      trending_me_interests.include?(article_concept).should be_true
    end
  end
end