require 'rest-client'
require 'json'
require 'colorize'

case ARGV[0]
when 'prd'
  url = "https://api.helloreverb.com/v2/audit/metrics"
when 'stg'
  url = "https://stage-api.helloreverb.com/v2/audit/metrics"
when 'dev'
  url = "https://dev-api.helloreverb.com/v2/audit/metrics"
else
  raise StandardError, "Need an ARGV[0] for which Bifrost env to monitor: prd, stg, or dev"
end

raise StandardError, "Need an ARGV[1] for how many seconds you want to sleep before querying audit metrics again" unless ARGV[1]

puts "News Wordwall\t|News Tiles\t|Me WordWall\t|Me Tiles\t|Article\t|Article Recs\t|Homescreen\t|Chirp\t|Profile\t|\
Collection\t|User Collections\t|Collection Recs\t|Interest Stream".yellow

1000.times do  
  r = RestClient.get url, :content_type => 'application/json'
  data = JSON.parse r

  news_wordwall = begin; data['com.wordnik.bifrost.apis.TrendingApi']['/trending/interests/global']['duration']['median'].to_s.match(/^\d{0,}/).to_s; rescue; 0; end
  news_tiles = begin; data['com.wordnik.bifrost.apis.TrendingApi']['/trending/tiles/global']['duration']['median'].to_s.match(/^\d{0,}/).to_s; rescue; 0; end
  me_wordwall = begin; data['com.wordnik.bifrost.apis.TrendingApi']['/trending/interests/me']['duration']['median'].to_s.match(/^\d{0,}/).to_s; rescue; 0; end
  me_tiles = begin; data['com.wordnik.bifrost.apis.TrendingApi']['/trending/tiles/me']['duration']['median'].to_s.match(/^\d{0,}/).to_s; rescue; 0; end
  article = begin; data['com.wordnik.bifrost.apis.ArticlesApi']['/articles/docId']['duration']['median'].to_s.match(/^\d{0,}/).to_s; rescue; 0; end
  article_recs = begin; data['com.wordnik.bifrost.apis.ArticlesApi']['/articles/recommendations']['duration']['median'].to_s.match(/^\d{0,}/).to_s; rescue; 0; end
  homescreen = begin; data['com.wordnik.bifrost.apis.SettingsApi']['/homescreen']['duration']['median'].to_s.match(/^\d{0,}/).to_s; rescue; 0; end
  chirp = begin; data['com.wordnik.bifrost.apis.AccountApi']['/account/chirpWithAuthSession']['duration']['median'].to_s.match(/^\d{0,}/).to_s; rescue; 0; end
  profile = begin; data['com.wordnik.bifrost.apis.UserProfileApi']['myProfile']['duration']['median'].to_s.match(/^\d{0,}/).to_s; rescue; 0; end
  collection = begin; data['com.wordnik.bifrost.apis.CollectionsApi']['/collection/get-collection']['duration']['median'].to_s.match(/^\d{0,}/).to_s; rescue; 0; end
  user_collections = begin; data['com.wordnik.bifrost.apis.CollectionsApi']['/collection/get-collections']['duration']['median'].to_s.match(/^\d{0,}/).to_s; rescue; 0; end
  collection_recs = begin; data['com.wordnik.bifrost.apis.CollectionsApi']['/collection/recommendations']['duration']['median'].to_s.match(/^\d{0,}/).to_s; rescue; 0; end
  interest_stream = begin; data['com.wordnik.bifrost.apis.InterestsApi']['/interests/stream']['duration']['median'].to_s.match(/^\d{0,}/).to_s; rescue; 0; end

  puts "#{news_wordwall}\t\t|#{news_tiles}\t\t|#{me_wordwall}\t\t|#{me_tiles}\t\t|#{article}\t\t|#{article_recs}\t\t|".green+
       "#{homescreen}\t\t|#{chirp}\t|#{profile}\t\t|#{collection}\t\t|#{user_collections}\t\t\t|#{collection_recs}\t\t\t|#{interest_stream}".green

  sleep ARGV[1].to_i
end
