require 'rest-client'
require 'colorize'
require 'json'
require 'date'

#raise StandardError, "\nNOTE: Command line argument is required: YYYY-MM-DD".yellow unless ARGV[0].to_s.match(/\d\d\d\d-\d\d-\d\d/)

date = ARGV[0].to_s

domain = 'https://stage-insights.helloreverb.com'
endpoint = 'api/rss.json/find-docs'

rss_feeds = []
bad_words = []

list_of_bad_words = File.dirname(__FILE__)+'/bad_words.txt'
list_of_rss_feeds = File.dirname(__FILE__)+'/rss_feeds.txt'

File.open(list_of_bad_words, "r").each_line do |line|
  bad_words << line.to_s.strip
end

File.open(list_of_rss_feeds, "r").each_line do |line|
  rss_feeds << line.to_s.strip
end
#rss_feeds = ['http://feeds.bbci.co.uk/news/uk/rss.xml']

rss_feeds.each do |feed|
  url = "#{domain}/#{endpoint}?skip=0&limit=500&feedUrl=#{feed}&sortOrderUp=undefined&env=stage"
  begin
    response = RestClient.post url, '', :content_type => 'application/x-www-form-urlencoded', :Authorization => 'Basic d2NsYWlib3JuZTpyZXZlcmJ0ZXN0MTIz'
  rescue => e
    puts url.red
    raise e, url
  end
  articles = JSON.parse response
  articles.each do |article|

    stage_success = nil
    today = nil

    article['corpusSubmissions'].each do |c|
      if c['env'] == 'stage' && c['result'] == 'success'
        stage_success = true
        #today = (Time.at(article['date'].match(/\A[0-9]{10}/).to_s.to_i+25200).to_datetime).to_s.match(/\A[^T]{1,}/).to_s == date.to_s
        today = true
        break
      else 
        stage_success = false
      end
    end

    if today && stage_success
      bad_words.each do |bad_word|
        title = article['title'].downcase+" "
        if title.match(/\s#{bad_word}\W/)
          puts "#{article['title'].yellow} contains '#{bad_word}'"
          puts article['url'].yellow
          puts ''
        end
      end
    end
  end
end