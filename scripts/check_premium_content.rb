require 'rest-client'
require 'colorize'
require 'json'
require 'date'

raise StandardError, "\nNOTE: Command line argument is required: YYYY-MM-DD".yellow unless ARGV[0].to_s.match(/\d\d\d\d-\d\d-\d\d/)

date = ARGV[0].to_s

domain = 'https://insights.helloreverb.com'
endpoint = 'api/rss.json/find-docs'

rss_feeds = []

list_of_rss_feeds = File.dirname(__FILE__)+'/rss_feeds.txt'

File.open(list_of_rss_feeds, "r").each_line do |line|
  rss_feeds << line.to_s.strip
end

failed_feeds = []

total_success = 0
total_failure = 0

rss_feeds.each do |feed|
  article_success = 0
  article_not_success = 0
  success = ''
  form_data = "skip=0&limit=500&feedUrl=#{feed}&sortOrderUp=undefined&env=prod"
  url = "#{domain}/#{endpoint}?#{form_data}"
  begin
    response = RestClient.post url, '', :content_type => 'application/x-www-form-urlencoded', :Authorization => 'Basic d2NsYWlib3JuZTpyZXZlcmJ0ZXN0MTIz'
  rescue => e
    puts url.red
    puts e.message
    failed_feeds << url
    next
  end
  articles = JSON.parse response
  articles.each do |article|
    begin
      article_date = (Time.at(article['date'].match(/\A[0-9]{10}/).to_s.to_i+25200).to_datetime).to_s.match(/\A[^T]{1,}/).to_s
    rescue
      failed_feeds << feed
      next
    end
    if article['corpusSubmissions']
      article['corpusSubmissions'].each do |c|
        if c['env'] == 'stage'
          success = c['result']
        end
      end
    else
      next 
    end
    #puts article_date+' '+success
    if article_date == date
      if success == 'success'
        article_success = article_success + 1
      else
        article_not_success = article_not_success + 1  
      end 
    end
  end
  fail_percent = "#{(article_not_success/(article_success+article_not_success))*100}%"
  puts article_success.to_s.green+' '+article_not_success.to_s.red+' '+"(#{fail_percent})".yellow+' '+feed
  total_success = total_success + article_success
  total_failure = total_failure + article_not_success
end
puts ''
puts "TOTAL SUCCESSES: #{total_success}"
puts "TOTAL FAILURES: #{total_failure}"
puts "FAILED FEEDS:\n#{failed_feeds}".yellow
