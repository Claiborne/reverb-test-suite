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
  puts bad_word
  %w(0 20).each do |skip|
    sleep 1
    print "+"
    url = URI::encode "http://10.190.152.196:8000/api/corpus.json/searchDocs?skip=#{skip}&limit=20&searchType=prefix&searchField=title&searchString=#{bad_word}&excludeReviewedDocs=false"
    begin
      res = RestClient.get url, :content_type => 'application/json', :Authorization => 'Basic d2NsYWlib3JuZTpyZXZlcmJ0ZXN0MTIz'
    rescue => e
      sleep 2 # wait for Corpus to recover
      puts "Could not search for #{bad_word}. There was a corpus error: #{e.message}"
      break
    end
    begin 
      data = JSON.parse res
    rescue 
      next
    end
    data.each do |d|
      ids << "#{d['id']} -- #{d['title']}"
    end
  end
end

output = "Attempting to delete "
output << "#{ids.count} articles\n"
output << "IDs and titles:\n"

ids.each do |id|
  id_num = id.match(/\A\d*/).to_s
  sleep 1
  url = "http://10.190.152.196:8000/api/corpus.json/deleteDocById?id=#{id_num}"
  begin
    RestClient.delete url,  :content_type => 'application/json', :Authorization => 'Basic d2NsYWlib3JuZTpyZXZlcmJ0ZXN0MTIz'
    output << "#{id}\n"
  rescue => e
    sleep 10 # wait for Corpus to recover
    puts e.message.to_s
  end
  print '.'
end

puts "AFTER"

output << "\n\n"
output << "Articles returned after deletions:\n"

bad_words.each do |bad_word|
  %w(0 20).each do |skip|
    sleep 1
    output << "--------------- #{bad_word} ---------------\n"
    url = URI::encode "http://10.190.152.196:8000/api/corpus.json/searchDocs?skip=#{skip}&limit=20&searchType=prefix&searchField=title&searchString=#{bad_word}&excludeReviewedDocs=false"
    begin
      res = RestClient.get url, :content_type => 'application/json', :Authorization => 'Basic d2NsYWlib3JuZTpyZXZlcmJ0ZXN0MTIz'
    rescue => e
      sleep 2 # wait for Corpus to recover
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
      output << "#{d['id']} -- #{d['title']}\n"
    end
  end
end

FROM_EMAIL = "reverbqualityassurance@gmail.com"
PASSWORD = "testpassword"
TO_EMAIL = ["caitlin@helloreverb.com","wclaiborne@helloreverb.com"]

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
