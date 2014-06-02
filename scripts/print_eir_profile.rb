require 'json'
require 'colorize'

raise StandardError, "Need an ARGV[0] for name of .json file on your desktop" unless ARGV[0]
file_name = ARGV[0]
file = File.open("/Users/wclaiborne/Desktop/#{file_name}.json", "rb")
@contents = JSON.parse file.read

def article_by_docid(t); begin; @contents['com.reverb.eir.api.ImageServingApi']['/article/:docid']['duration'][t].to_s.match(/^\d{0,}/).to_s; rescue; 0; end; end
def composite(t); begin; @contents['com.reverb.eir.api.ImageServingApi']['/composite']['duration'][t].to_s.match(/^\d{0,}/).to_s; rescue; 0; end; end
def concept_by_name(t); begin; @contents['com.reverb.eir.api.ImageServingApi']['/concept/:name']['duration'][t].to_s.match(/^\d{0,}/).to_s; rescue; 0; end; end

puts 'Article'.yellow
['median','p75','p95'].each do |t|
  puts "\t#{article_by_docid(t)}".green+"\t#{t}"
end

puts 'Composite'.yellow
['median','p75','p95'].each do |t|
  puts "\t#{composite(t)}".green+"\t#{t}"
end

puts 'Concept'.yellow
['median','p75','p95'].each do |t|
  puts "\t#{concept_by_name(t)}".green+"\t#{t}"
end
