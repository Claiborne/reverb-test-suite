require 'rest-client'
require 'colorize'
require 'json'
require 'date'
require 'time'
require 'net/smtp'

# Search corpus for bad words in title

output = "Results "
output << "for:\n"
output << "#{Time.now}\n"
bad_words = []
flagged_content = []
time_now = Time.now.to_i
 
File.open(File.dirname(__FILE__)+'/bad_words.txt', "r").each_line do |line|
  bad_words << line.to_s.downcase.strip
end

bad_words.each do |bad_word|
  output << "--------------- #{bad_word} ---------------\n"
  %w(0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200).each do |skip|
    sleep 1
    url = URI::encode "http://10.190.152.196:8000/api/corpus.json/searchDocs?skip=#{skip}&limit=10&searchType=prefix&searchField=title&searchString=#{bad_word}&excludeReviewedDocs=false"
    begin
      res = RestClient.get url, :content_type => 'application/json', :Authorization => 'Basic d2NsYWlib3JuZTpyZXZlcmJ0ZXN0MTIz'
    rescue => e
      sleep 35 # wait for Corpus to recover
      begin
        res = RestClient.get url, :content_type => 'application/json', :Authorization => 'Basic d2NsYWlib3JuZTpyZXZlcmJ0ZXN0MTIz'
      rescue
        output << "     There was a corpus error: #{e.message}\n"
        break
      end
    end
    begin
      data = JSON.parse res
    rescue => e
      output << "There was a corpus error: JSON not returned from Corpus. #{e.message}\n"
      break
    end
    data.each do |d|
      puts d['createDate']
      output << "#{d['title']}\n" if (time_now - Time.parse(d['createDate'].to_s).to_i) < 86400
    end
  end
end

FROM_EMAIL = "reverbqualityassurance@gmail.com"
PASSWORD = "testpassword"
TO_EMAIL = ["caitlin@helloreverb.com"]

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
