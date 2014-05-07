require 'json'
require 'rest_client'
require 'thread'

tokens = []
articles = []

File.open("/Users/wclaiborne/Documents/load_test_05_2014/stg_tokens.txt", "r").each_line do |line|
  tokens << line.strip
end

File.open("/Users/wclaiborne/Documents/load_test_05_2014/articles.stage.ids.500000.txt", "r").each_line do |line|
  articles << line.strip
end

tokens.each do |session|

puts session
4.times do 

  url = "https://stage-api.helloreverb.com/v2/events/click?deviceId=load-test&api_key=#{session}"
  article = articles[rand(articles.length)]
  puts article

  read_article = {
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
      "value"=>article
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
      "startTime"=>Time.now.to_i
      }
    ]
  }.to_json

  exit_article = {
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
      "startTime"=>Time.now.to_i
      }
    ]
  }.to_json

  res = RestClient.post url, read_article, 'Content-Type' => 'application/json'
  sleep 1
  res = RestClient.post url, exit_article, 'Content-Type' => 'application/json' 
end; end
