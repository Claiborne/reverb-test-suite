require 'RestClient'
@url = "https://api.helloreverb.com/v2/trending/tiles/me?skip=0&api_key=d41308d6a8b86e610cbfd4ce480f47699fad9b035a288b23"
@headers = {:content_type => 'application/json', :accept => 'application/json'}
100.times do 
  begin
    response = RestClient.get @url, @headers
  rescue => e
    raise StandardError.new(e.message+" "+@url)
  end
end