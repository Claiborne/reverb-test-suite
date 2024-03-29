require 'rest-client'
require 'colorize'
require 'json'
require 'date'

# Search corpus for bad words in title

raise StandardError, "\nNOTE: Command line argument is required: YYYY-MM-DD".yellow unless ARGV[0].to_s.match(/\d\d\d\d-\d\d-\d\d/)

date = ARGV[0].to_s

bad_words = []
flagged_content = []

File.open(File.dirname(__FILE__)+'/bad_words.txt', "r").each_line do |line|
  bad_words << line.to_s.downcase.strip
end

bad_words.each do |bad_word|
  %w(0 100 200 300 400 500).each do |skip|
    puts "--------------- #{bad_word} ---------------"
    url = URI::encode "https://insights.helloreverb.com/proxy/corpus-service/api/corpus.json/searchDocs?skip=#{skip}&limit=100&searchType=prefix&searchField=title&searchString=#{bad_word}&excludeReviewedDocs=false"
    begin
      res = RestClient.get url, :content_type => 'application/json', :Authorization => 'Basic d2NsYWlib3JuZTpyZXZlcmJ0ZXN0MTIz'
    rescue => e
      puts "COULD NOT SEARCH FOR #{bad_word}. There was a corpus error: #{e.message}"
      next
    end
    data = JSON.parse res
    data.each do |d|
      (puts d['title']) if d['createDate'].match(date)
    end
    break unless data.count > 99
  end
end
