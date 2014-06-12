 module ReadArticle

  def read_article_iphone(time, article)
    {
    "events"=> [ 
      {
      "eventArgs" => [ 
        {"name"=>"docId","value"=>article.to_s},
        {"name"=>"view","value"=>"1"},
        {"name"=>"wasSwipe","value"=>"0"},
        {"name"=>"rank","value"=>"1"},
        {"name"=>"featured","value"=>"0"}
      ],
      "eventType"=>"iphoneChooseArticle",
      "location"=>{"lat"=>37.785852,"lon"=>-122.406529},
      "startTime"=>(time.to_i*1000)}
    ]
    }.to_json
  end

  def exit_article_iphone(time)
    {
    "events" => [
      {
      "eventArgs" => [
        {"name"=>"iphoneTapHome"}
      ],
      "eventType"=>"iphoneTapHome",
      "location"=>{"lat"=>37.785852,"lon"=>-122.406529},
      "startTime"=>(time.to_i*1000)}
    ]
    }.to_json
  end
  
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
      "value"=>article.to_s
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
      "startTime"=>(time.to_i*1000)
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
        "startTime"=>(time.to_i*1000)
        }
      ]
    }.to_json
  end
end
