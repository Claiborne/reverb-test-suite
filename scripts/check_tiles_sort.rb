require 'rest-client'
require 'json'

@skip = 0
@limit = 24
@api_key = '372c469080528dee31ec20b4f89241348d1ebde65a264e0e'

30.times do
  puts ''
  #url = "https://stage-api.helloreverb.com/v2/trending/tiles/me?skip=#{@skip}&limit=#{@limit}&api_key=#{@api_key}&format=json"
  url = "https://stage-api.helloreverb.com/v2/trending/tiles/social?skip=#{@skip}&api_key=ca3d2ddd98c2dfae653f6acc6937458eb9fcdf0ac8a82f78&format=json"
  res = RestClient.get url
  data = JSON.parse res
  @skip = @skip + data['tiles'].count
  data['tiles'].each do |d|
    #puts d['publishDate'].match(/\d\d\d\d-\d\d-\d\d/).to_s+"  --  "+d['contentId'].to_s if d['tileType'] == 'article'
    puts d['attribution'][0]['shareDate'].match(/\d\d\d\d-\d\d-\d\d/).to_s+"  --  "+d['contentId'].to_s if d['tileType'] == 'article'
  end
  puts ''
end