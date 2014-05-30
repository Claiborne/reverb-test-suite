require 'json'
require 'rest_client'
require 'thread'

tokens = ['c86d83b8aebe83bb9c1e3e5a357a4f3f902410c2ac8c6fa2']
articles = []

=begin
File.open("/Users/wclaiborne/Documents/load_test_05_2014/stg_tokens.txt", "r").each_line do |line|
  tokens << line.strip
end
=end
#cake = ['43927335']
cake = ['43927335','43872413','43872454','43906389','43891845']
rose = ['43925386','43901483','43916689']
both = cake+rose

=begin
File.open("/Users/wclaiborne/code/reverb-performance-suite/load_test_05_2014/articles.stage.ids.500000.txt", "r").each_line do |line|
  articles << line.strip
end
=end

tokens.each do |session|

puts session
cake.each do |article| 

  url = "https://stage-api.helloreverb.com/v2/events/click?deviceId=load-test&api_key=#{session}"
  #article = cake[rand(articles.length)]
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
      "startTime"=>Time.now.to_i*1000
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
      "startTime"=>Time.now.to_i*1000
      }
    ]
  }.to_json

  res = RestClient.post url, read_article, 'Content-Type' => 'application/json'
  sleep 1
  res = RestClient.post url, exit_article, 'Content-Type' => 'application/json' 
end; end
