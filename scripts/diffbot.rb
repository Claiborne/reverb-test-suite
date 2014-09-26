require 'rest-client'
require 'json'
require 'colorize'

def get_article_urls(approx_number_of_articles)
  urls = []
  skip = 0
  while skip < approx_number_of_articles
    response = RestClient.get "https://api.helloreverb.com/v2/trending/tiles/global?format=json&skip=#{skip}&limit=24&api_key=f6dee50d0af730d126397bb60b094cbe9486aebf8a84bcd4"
    data = JSON.parse(response)
    data['tiles'].each do |article|
      urls << article['shareUrl'] if article['tileType'] == 'article'
    end
    skip+= 24
  end # end while
  urls
end

# begin script

urls = get_article_urls ARGV[0].to_i
url_count = urls.count

diffbot_endpoint = "https://api.diffbot.com/v2/analyze?fields=*&stats=*&mode=article&timeout=60000&token=7cbd65f8f126f4ad91a32e2674e578af&url="

errors = []
successes = []

urls.each do |url|
  begin
    start = Time.now
    begin
      response = RestClient.get diffbot_endpoint+url
    rescue => e
      errors << "#{url}\n#{e.message}\n"
      next
    end
    finish = Time.now

    doc = JSON.parse response


    if doc['type'] == 'article' 
    else
      errors << "#{url}\ndoc['type']\n"
      next
    end

    if doc['text'].length > 49
      successes << (finish-start).floor
    else
      errors << "#{url}\ndoc['text'].length\n"
      next
    end
  rescue => e
    errors << "#{url}\nuncaught error #{e.message}\n"
  end # end catch all
end # end url iteration

percent_failure = errors.count/url_count.to_f*100
def average_time(arr) 
  arr.inject(0.0) { |sum, el| sum + el } / arr.size
end

puts ''
puts "Failure Percentage: #{percent_failure}%".green
puts ''
puts "Average response time: #{average_time successes}".green
puts ''
puts "URLS Checked: #{url_count}".yellow
puts ''
puts "Successes: #{successes.sort}".yellow
puts ''
puts "Errors\n".yellow
errors.each do |error|
  puts "#{error}".yellow
end
puts ''

