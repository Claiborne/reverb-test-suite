require 'rest-client'
require 'rspec'

describe "URL" do

  it 'should return 200' do
    url = "https://dev-api.helloreverb.com/v2/interests/stream?interest=Risk&skip=0&limit=50&api_key=6ccdaffb9294bcbedae3c7a2b2194235939a079ec7ebf282"
    count = 40
    pause = 0
    count.times do 
      sleep(pause)
      begin
        response = RestClient.get url
      rescue => e
        raise StandardError.new(e.message+" "+url)
      end
    end
  end
end