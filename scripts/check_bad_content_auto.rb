require 'rest-client'
require 'colorize'
require 'json'
require 'date'
require 'net/smtp'

# Search corpus for bad words in title

output = "Results "
output << "for:\n"
output << "#{Time.now}\n"
bad_words = []
flagged_content = []
today = (Time.now.to_s.match /\d\d\d\d-\d\d\-\d\d/).to_s
 
File.open(File.dirname(__FILE__)+'/bad_words.txt', "r").each_line do |line|
  bad_words << line.to_s.strip
end

bad_words.each do |bad_word|
  %w(0 100 200 300 400 500).each do |skip|
    output << "--------------- #{bad_word} ---------------\n"
    url = URI::encode "https://insights.helloreverb.com/proxy/corpus-service/api/corpus.json/searchDocs?skip=#{skip}&limit=100&searchType=prefix&searchField=title&searchString=#{bad_word}&excludeReviewedDocs=false"
    begin
      res = RestClient.get url, :content_type => 'application/json', :Authorization => 'Basic d2NsYWlib3JuZTpyZXZlcmJ0ZXN0MTIz'
    rescue => e
      output << "COULD NOT SEARCH FOR #{bad_word}. There was a corpus error: #{e.message}"
      next
    end
    data = JSON.parse res
    data.each do |d|
      output << "#{d['title']}\n" if d['createDate'].match(today)
    end
    break unless data.count > 99
  end
end

FROM_EMAIL = "everbqualityassurance@gmail.com"
PASSWORD = "testpassword"
TO_EMAIL = "caitlin@helloreverb.com"

msgstr = <<END_OF_MESSAGE
From: Reverb QA <#{FROM_EMAIL}>
To: Caitlin <#{TO_EMAIL}>
Subject: Flagged Article Titles from QA
#{output}
END_OF_MESSAGE

smtp = Net::SMTP.new 'smtp.gmail.com', 587
smtp.enable_starttls
smtp.start('gmail.com', 'reverbqualityassurance', PASSWORD, :login) do |smtp|
  smtp.send_message msgstr, FROM_EMAIL, TO_EMAIL
end