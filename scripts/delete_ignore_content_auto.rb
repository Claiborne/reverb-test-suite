require 'rest-client'
require 'colorize'
require 'json'
require 'date'
require 'net/smtp'

# Get a list of ignore sites

ignore_site_list = []

headers = {:content_type => 'application/json', :Authorization => 'Basic d2NsYWlib3JuZTpyZXZlcmJ0ZXN0MTIz'}
ignore_sites = "https://insights.helloreverb.com/proxy/corpus-service/api/site.json/ignoreSiteDetails"

begin
  res = RestClient.get ignore_sites, headers
rescue => e
  raise StandardError.new(e.message+":\n"+ignore_sites)
end

ignore_sites_data = JSON.parse res

ignore_sites_data['siteIds'].each { |site| ignore_site_list << site.to_s unless site.to_i == 459022}
#ignore_sites_data['siteUrls'].each { |site| ignore_site_list << site.to_s }
#ignore_sites_data['domains'].each { |site| ignore_site_list << site.to_s }

# Get site ids
=begin
ignore_site_id_list = []

ignore_site_list.each do |site|

  ignore_site = URI::encode "https://insights.helloreverb.com/api/sites.json/sites?&searchString=#{site}"

  begin
    res = RestClient.get ignore_site, headers
  rescue => e
    puts "Could not search for #{site}. There was an error: #{e.message}"
    next
  end
  begin
    data = JSON.parse res
  rescue => e
    puts "Could not parse data for #{site}. There was an error: #{e.message}"
    next
  end

  puts "#{site}"

  data.each do |d|
    puts "  "+d['id'].to_s
    puts "  "+d['url'].to_s
    ignore_site_id_list << d['id']
  end

end
=end
# Search Corpus for articles by site id

ids = []
ignore_site_list.each do |site|
  print "-"
  #puts "--------------- #{site} ---------------\n"
  url = "https://insights.helloreverb.com/proxy/corpus-service/api/corpus.json/#{site}?skip=0&limit=100&createdAfter=05/01/2013%200:0:0&excludeReviewedDocs=false"
  begin
    res = RestClient.get url, :content_type => 'application/json', :Authorization => 'Basic d2NsYWlib3JuZTpyZXZlcmJ0ZXN0MTIz'
  rescue => e
    puts "Could not search for #{site}. There was a corpus error: #{e.message}"
    next
  end
  begin 
    data = JSON.parse res
  rescue => e
    puts "Could not parse data returned by searching #{site}. There was an error: #{e.message}"
    next
  end
  data.each do |d|
    ids << d['id']
    ids << d['title']
  end
end

puts ids
puts "Count: #{ids.count}"
=begin
ids.each do |id|
  url = "https://insights.helloreverb.com/proxy/corpus-service/api/corpus.json/deleteDocById?id=#{id}"
  begin
    RestClient.delete url,  :content_type => 'application/json', :Authorization => 'Basic d2NsYWlib3JuZTpyZXZlcmJ0ZXN0MTIz'
  rescue => e
    puts e.message.to_s
  end
  print '.'
end
=end
