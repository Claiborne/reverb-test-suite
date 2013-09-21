require 'rest_client'
require 'json'

%w(0).each do |skip|

  response = RestClient.get "https://dev-api.helloreverb.com/v2/trending/tiles/me?format=json&skip=#{skip}&limit=150&api_key=e891a91f35d84fbe4cce308ef9844c8eb35c956a15f17cd5"

  data = JSON.parse(response)

  data['tiles'].each do |article|
    puts article['contentId']
  end

end
