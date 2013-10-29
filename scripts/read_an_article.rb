
require 'json'
require 'rest_client'
require 'thread'

session = 'f1d225e572448338449577031d7140c5888b1fd37f481cde'
url = "https://stage-api.helloreverb.com/v2/events/click?deviceId=load-test&api_key=#{session}"

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
    "value"=> "41939621"
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
sleep 15
res = RestClient.post url, exit_article, 'Content-Type' => 'application/json' 

