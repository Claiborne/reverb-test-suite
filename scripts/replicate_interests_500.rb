require 'rest_client'
require 'json'

interests_list = ['News',
'Crafts & DIY',
'Gaming',
'History & Culture',
'Books',
'Sports',
'Fitness',
'Business & Economy',
'Health',
'Pets',
'Food',
'Politics',
'Television',
'Music',
'Art & Design',
'Humor',
'Fashion & Style',
'Autos',
'Movies & Theater',
'Travel',
'Parenting',
'Celebrity',
'Technology',
'Science',
'Home & Garden',
'Nature',
'Philippines',
'Rob Ford',
'Debate',
'Dinner',
'Hurdling',
'Foreign exchange market',
'Recall election',
'Toronto',
'Election',
'NPR',
'Latin America',
'Actor',
'California',
'Iran',
'Lawyer',
'Nuclear power',
'Democratic Republic of the Congo',
'Girlfriend',
'Sales',
'Video game',
'Police',
'Manufacturing',
'Percentage',
'Diplomacy',
'Twitter',
'University of Texas at Austin',
'Supercomputer',
'CNN',
'Domestic violence']

def get_anon_token(base_url)
  endpoint = "#{base_url}account/ohai?clientId=515b32b0e4b03f3544d60a15&format=json"
  body = {"deviceId"=>"reverb-test-suite"}.to_json
  begin 
    response = RestClient.post endpoint, body, :content_type => "application/json"
  rescue => e
    raise StandardError.new(e.message+" "+endpoint)
  end
  data = JSON.parse response
  data['token']
end

url = "https://api.helloreverb.com/v2/trending/interests/global?skip=0&limit=100&api_key=#{get_anon_token 'https://api.helloreverb.com/v2/'}"
begin
  response = RestClient.get url, {:content_type => 'application/json', :accept => 'application/json'}
rescue => e
  raise StandardError.new(e.message+":\n"+url)
end
interests = (JSON.parse response)['interests']
interests.each {|i| interests_list << i['value']}

2.times do 
  %w(me global).each do |scope|
    interests_list.each do |interest|
      print '.'
      url = "https://api.helloreverb.com/v2/interests/stream/#{scope}?interest=#{CGI::escape interest}&skip=0&limit=50&api_key=#{get_anon_token 'https://api.helloreverb.com/v2/'}"
      begin
        response = RestClient.get url, {:content_type => 'application/json', :accept => 'application/json'}
      rescue RestClient::ResourceNotFound => e
        errors << url
        next
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
    end
  end
end
