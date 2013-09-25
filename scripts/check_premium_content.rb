require 'rest-client'
require 'colorize'
require 'json'
require 'date'

raise StandardError, "\nNOTE: Command line argument is required: YYYY-MM-DD".yellow unless ARGV[0].to_s.match(/\d\d\d\d-\d\d-\d\d/)

date = ARGV[0].to_s

domain = 'http://stage-insights.helloreverb.com'
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
  form_data = "skip=0&limit=500&feedUrl=#{feed}&sortOrderUp=undefined&env=stage"
  response = RestClient.post "#{domain}/#{endpoint}?#{form_data}", '', :content_type => 'application/x-www-form-urlencoded'
  articles = JSON.parse response
  articles.each do |article|
    begin
      article_date = (Time.at(article['date'].match(/\A[0-9]{10}/).to_s.to_i+25200).to_datetime).to_s.match(/\A[^T]{1,}/).to_s
     success = article['corpusSubmissions'][0]['result']
    rescue
      failed_feeds << feed
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
  puts article_success.to_s.green+' '+article_not_success.to_s.red+' '+feed
  total_success = total_success + article_success
  total_failure = total_failure + article_not_success
end
puts "TOTAL SUCCESSES: #{total_success}"
puts "TOTAL FAILURES: #{total_failure}"
puts "FAILED FEEDS:\n#{failed_feeds}".yellow
