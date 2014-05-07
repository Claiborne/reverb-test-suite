require 'rest-client'
require 'json'

@skip = 0
@limit = 24
@api_key = 'a13931ff647dbb20239c8c385fa0421688e88ccce172903c'

40.times do
  #url = "https://stage-api.helloreverb.com/v2/trending/tiles/me?skip=#{@skip}&limit=#{@limit}&api_key=#{@api_key}&format=json"
  url = "https://api.helloreverb.com/v2/trending/tiles/global?skip=#{@skip}&api_key=#@api_key&format=json"
  res = RestClient.get url
  data = JSON.parse res
  @skip = @skip + data['tiles'].count
  data['tiles'].each do |d|
    puts d['publishDate'].match(/\d\d\d\d-\d\d-\d\d/).to_s if d['tileType'] == 'article'
    #puts d['publishDate'].match(/\d\d\d\d-\d\d-\d\d/).to_s+"  --  "+d['contentId'].to_s if d['tileType'] == 'article'
    #puts d['attribution'][0]['shareDate'].match(/\d\d\d\d-\d\d-\d\d/).to_s+"  --  "+d['contentId'].to_s if d['tileType'] == 'article'
  end
  #puts ''
end
