require 'json'
require 'colorize'

raise StandardError, "Need an ARGV[0] for name of .json file on your desktop" unless ARGV[0]
file_name = ARGV[0]
file = File.open("/Users/wclaiborne/Desktop/#{file_name}.json", "rb")
@contents = JSON.parse file.read

def news_wordwall(t); begin; @contents['com.wordnik.bifrost.apis.TrendingApi']['/trending/interests/global']['duration'][t].to_s.match(/^\d{0,}/).to_s; rescue; 0; end; end
def news_tiles(t) begin; @contents['com.wordnik.bifrost.apis.TrendingApi']['/trending/tiles/global']['duration'][t].to_s.match(/^\d{0,}/).to_s; rescue; 0; end; end
def me_wordwall(t) begin; @contents['com.wordnik.bifrost.apis.TrendingApi']['/trending/interests/me']['duration'][t].to_s.match(/^\d{0,}/).to_s; rescue; 0; end; end
def me_tiles(t) begin; @contents['com.wordnik.bifrost.apis.TrendingApi']['/trending/tiles/me']['duration'][t].to_s.match(/^\d{0,}/).to_s; rescue; 0; end; end
def article(t) begin; @contents['com.wordnik.bifrost.apis.ArticlesApi']['/articles/docId']['duration'][t].to_s.match(/^\d{0,}/).to_s; rescue; 0; end; end
def article_recs(t) begin; @contents['com.wordnik.bifrost.apis.ArticlesApi']['/articles/recommendations']['duration'][t].to_s.match(/^\d{0,}/).to_s; rescue; 0; end; end
def homescreen(t) begin; @contents['com.wordnik.bifrost.apis.SettingsApi']['/homescreen']['duration'][t].to_s.match(/^\d{0,}/).to_s; rescue; 0; end; end
def chirp(t) begin; @contents['com.wordnik.bifrost.apis.AccountApi']['/account/chirpWithAuthSession']['duration'][t].to_s.match(/^\d{0,}/).to_s; rescue; 0; end; end
def profile(t) begin; @contents['com.wordnik.bifrost.apis.UserProfileApi']['myProfile']['duration'][t].to_s.match(/^\d{0,}/).to_s; rescue; 0; end; end
def collection(t) begin; @contents['com.wordnik.bifrost.apis.CollectionsApi']['/collection/get-collection']['duration'][t].to_s.match(/^\d{0,}/).to_s; rescue; 0; end; end
def user_collections(t) begin; @contents['com.wordnik.bifrost.apis.CollectionsApi']['/collection/get-collections']['duration'][t].to_s.match(/^\d{0,}/).to_s; rescue; 0; end; end
def collection_recs(t) begin; @contents['com.wordnik.bifrost.apis.CollectionsApi']['/collection/recommendations']['duration'][t].to_s.match(/^\d{0,}/).to_s; rescue; 0; end; end
def interest_stream(t) begin; @contents['com.wordnik.bifrost.apis.InterestsApi']['/interests/stream']['duration'][t].to_s.match(/^\d{0,}/).to_s; rescue; 0; end; end
def interest_search(t) begin; @contents['com.wordnik.bifrost.apis.InterestsApi']['/interests/search']['duration'][t].to_s.match(/^\d{0,}/).to_s; rescue; 0; end; end
def heimdall(t) begin; @contents['com.reverb.clients.heimdall.apis.AuthClient']['simpleTokenAuthentication']['duration'][t].to_s.match(/^\d{0,}/).to_s; rescue; 0; end; end



puts 'News Wordwall'.yellow
['median','p75','p95'].each do |t|
  puts "\t#{news_wordwall(t)}".green+"\t#{t}"
end
puts 'News Tiles'.yellow
['median','p75','p95'].each do |t|
  puts "\t#{news_tiles(t)}".green+"\t#{t}"
end
puts 'Me Wordwall'.yellow
['median','p75','p95'].each do |t|
  puts "\t#{me_wordwall(t)}".green+"\t#{t}"
end
puts 'Me Tiles'.yellow
['median','p75','p95'].each do |t|
  puts "\t#{me_tiles(t)}".green+"\t#{t}"
end
puts 'Article'.yellow
['median','p75','p95'].each do |t|
  puts "\t#{article(t)}".green+"\t#{t}"
end
puts 'Aricle Recs'.yellow
['median','p75','p95'].each do |t|
  puts "\t#{article_recs(t)}".green+"\t#{t}"
end
puts 'Homescreen'.yellow
['median','p75','p95'].each do |t|
  puts "\t#{homescreen(t)}".green+"\t#{t}"
end
puts 'Chirp'.yellow
['median','p75','p95'].each do |t|
  puts "\t#{chirp(t)}".green+"\t#{t}"
end
puts 'Profile'.yellow
['median','p75','p95'].each do |t|
  puts "\t#{profile(t)}".green+"\t#{t}"
end
puts 'Collection'.yellow
['median','p75','p95'].each do |t|
  puts "\t#{collection(t)}".green+"\t#{t}"
end
puts 'User Collections'.yellow
['median','p75','p95'].each do |t|
  puts "\t#{user_collections(t)}".green+"\t#{t}"
end
puts 'Collection Recs'.yellow
['median','p75','p95'].each do |t|
  puts "\t#{collection_recs(t)}".green+"\t#{t}"
end
puts 'Interest Stream'.yellow
['median','p75','p95'].each do |t|
  puts "\t#{interest_stream(t)}".green+"\t#{t}"
end
puts 'Interest Search' .yellow
['median','p75','p95'].each do |t|
  puts "\t#{interest_search(t)}".green+"\t#{t}"
end
puts 'Heimdall' .yellow
['median','p75','p95'].each do |t|
  puts "\t#{heimdall(t)}".green+"\t#{t}"
end

