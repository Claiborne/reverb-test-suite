require './../functional/lib/bifrost/token.rb'; include Token
require 'rest_client'
require 'json'
require 'time'
require 'net/smtp'

contents = ""
contents << Time.now.to_s+"\n"
contents << "\n"
contents << "The last tier one article showing in the followig app:\n"
contents << "\n"

%w(api.helloreverb.com basil-api.helloreverb.com anise-api.helloreverb.com 
thyme-api.helloreverb.com nutmeg-api.helloreverb.com).each do |bifrost_env|

  token = get_anon_token "#{bifrost_env}/v2"
  url = "https://"+bifrost_env+"/v2/trending/tiles/global?skip=0&limit=24&api_key="+token

  begin
    r = RestClient.get url, {:content_type => 'application/json', :accept => 'application/json'}
  rescue => e
    raise StandardError.new(e.message+":\n"+url)
  end
  news_tiles = JSON.parse r
  first_article_publish_date = Time.parse(news_tiles['tiles'][0]['publishDate']).to_i
  time_difference_in_hours = (Time.now.utc.to_i - first_article_publish_date)/(60*60)
  contents << "#{bifrost_env} #{time_difference_in_hours} hours ago\n"
end

begin
  file = File.open("/home/wclaiborne/tier-one-article-ingestion-results.txt", 'w')
  file.write(contents) 
rescue IOError => e
  #some error occur, dir not writable etc.
ensure
  file.close unless file == nil
end

FROM_EMAIL = "reverbqualityassurance@gmail.com"
PASSWORD = "testpassword"
TO_EMAIL = ["qa@helloreverb.com","conner@helloreverb.com","marco@helloreverb.com"]

msgstr = <<END_OF_MESSAGE
From: Reverb QA (Do not reply) <#{FROM_EMAIL}>
To: QA <#{TO_EMAIL}>
Subject: Tier One Aticle Ingestion Smoke Test
#{contents}
END_OF_MESSAGE

smtp = Net::SMTP.new 'smtp.gmail.com', 587
smtp.enable_starttls
smtp.start('gmail.com', 'reverbqualityassurance', PASSWORD, :login) do |smtp|
  smtp.send_message msgstr, FROM_EMAIL, TO_EMAIL
end
