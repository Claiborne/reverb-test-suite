require 'rest-client'
require 'colorize'
require 'json'
require 'date'
require 'net/smtp'
 
bad_words = []
ids = []

File.open(File.dirname(__FILE__)+'/bad_words_autodelete.txt', "r").each_line do |line|
  bad_words << line.to_s.downcase.strip
end

puts "BEFORE"

bad_words.each do |bad_word|
  sleep 1
  %w(0 100 200 300 400 500).each do |skip|
    #puts "--------------- #{bad_word} ---------------\n"
    print "+"
    url = URI::encode "https://insights.helloreverb.com/proxy/corpus-service/api/corpus.json/searchDocs?skip=#{skip}&limit=100&searchType=prefix&searchField=title&searchString=#{bad_word}&excludeReviewedDocs=false"
    begin
      res = RestClient.get url, :content_type => 'application/json', :Authorization => 'Basic d2NsYWlib3JuZTpyZXZlcmJ0ZXN0MTIz'
    rescue => e
      sleep 7 # wait for Corpus to recover
      puts "Could not search for #{bad_word}. There was a corpus error: #{e.message}"
      next
    end
    begin 
      data = JSON.parse res
    rescue 
      next
    end
    data.each do |d|
      #puts "#{d['title']}\n"
      ids << d['id']
    end
    break unless data.count > 99
  end
end

ids.each do |id|
  sleep 1
  url = "https://insights.helloreverb.com/proxy/corpus-service/api/corpus.json/deleteDocById?id=#{id}"
  begin
    RestClient.delete url,  :content_type => 'application/json', :Authorization => 'Basic d2NsYWlib3JuZTpyZXZlcmJ0ZXN0MTIz'
  rescue => e
    sleep 7 # wait for Corpus to recover
    puts e.message.to_s
  end
  print '.'
end

puts "AFTER"

output = "Deleted "
output << "#{ids.count} articles\n\n"
output << "Results "
output << "for:\n"
output << "#{Time.now}\n"

bad_words.each do |bad_word|
  %w(0 100 200 300 400 500).each do |skip|
    output << "--------------- #{bad_word} ---------------\n"
    url = URI::encode "https://insights.helloreverb.com/proxy/corpus-service/api/corpus.json/searchDocs?skip=#{skip}&limit=100&searchType=prefix&searchField=title&searchString=#{bad_word}&excludeReviewedDocs=false"
    begin
      res = RestClient.get url, :content_type => 'application/json', :Authorization => 'Basic d2NsYWlib3JuZTpyZXZlcmJ0ZXN0MTIz'
    rescue => e
      sleep 7 # wait for Corpus to recover
      output << "COULD NOT SEARCH FOR #{bad_word}. There was a corpus error: #{e.message}"
      break
    end
    begin 
      data = JSON.parse res
    rescue 
      output << "NOTE: CORPUS DID NOT RETRUN VALID DATA for #{bad_word}. Please search for content manually and delete" 
      break
    end
    data.each do |d|
      output << "#{d['title']}\n"
    end
    break unless data.count > 99
  end
end

FROM_EMAIL = "reverbqualityassurance@gmail.com"
PASSWORD = "testpassword"
TO_EMAIL = "caitlin@helloreverb.com"

msgstr = <<END_OF_MESSAGE
From: Reverb QA <#{FROM_EMAIL}>
To: Caitlin <#{TO_EMAIL}>
Subject: Bad Articles After Deletion Script
#{output}
END_OF_MESSAGE

smtp = Net::SMTP.new 'smtp.gmail.com', 587
smtp.enable_starttls
smtp.start('gmail.com', 'reverbqualityassurance', PASSWORD, :login) do |smtp|
  smtp.send_message msgstr, FROM_EMAIL, TO_EMAIL
end
