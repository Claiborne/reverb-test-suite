require 'nokogiri'
require 'rest_client'

# Example of how to run
# ruby link_checker.rb 'div#page-wrapper nav' www.helloreverb.com

puts ""
puts "BROKEN LINKS:"

css_selector = ARGV[0]
url = ARGV[1]

@doc = Nokogiri::HTML(RestClient.get(url))

links = []
@doc.css("#{css_selector} a").each do |link|
  links << link.attribute('href').to_s unless link.attribute('href').to_s.match(/\A(#|\/)/)
end

puts "(checking #{links.count} links)"

links.each do |link|

  begin
    RestClient.get link
  rescue
    puts link.to_s
  end
end
puts ""