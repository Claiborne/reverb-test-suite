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

puts "News Wordwall\t|News Tiles\t|Me WordWall\t|Me Tiles\t|Article\t|Article Recs\t|Homescreen\t|Chirp\t\t|Profile\t|\
Collection\t|User Collections\t|Collection Recs\t|Interest Stream\t|Interest Search\t|Login\t\t|ohai".yellow

1000.times do  
  r = RestClient.get url, :content_type => 'application/json'
  data = JSON.parse r

  news_wordwall = begin; "#{data['com.wordnik.bifrost.apis.TrendingApi']['/trending/interests/global']['duration']['mean'].to_s.match(/^\d{0,}/)} / #{data['com.wordnik.bifrost.apis.TrendingApi']['/trending/interests/global']['duration']['p95'].to_s.match(/^\d{0,}/)}"; rescue; 0; end
  news_tiles = begin; "#{data['com.wordnik.bifrost.apis.TrendingApi']['/trending/tiles/global']['duration']['mean'].to_s.match(/^\d{0,}/)} / #{data['com.wordnik.bifrost.apis.TrendingApi']['/trending/tiles/global']['duration']['p95'].to_s.match(/^\d{0,}/)}"; rescue; 0; end
  me_wordwall = begin; "#{data['com.wordnik.bifrost.apis.TrendingApi']['/trending/interests/me']['duration']['mean'].to_s.match(/^\d{0,}/)} / #{data['com.wordnik.bifrost.apis.TrendingApi']['/trending/interests/me']['duration']['p95'].to_s.match(/^\d{0,}/)}"; rescue; 0; end
  me_tiles = begin; "#{data['com.wordnik.bifrost.apis.TrendingApi']['/trending/tiles/me']['duration']['mean'].to_s.match(/^\d{0,}/)} / #{data['com.wordnik.bifrost.apis.TrendingApi']['/trending/tiles/me']['duration']['p95'].to_s.match(/^\d{0,}/)}"; rescue; 0; end
  article = begin; "#{data['com.wordnik.bifrost.apis.ArticlesApi']['/articles/docId']['duration']['mean'].to_s.match(/^\d{0,}/)} / #{data['com.wordnik.bifrost.apis.ArticlesApi']['/articles/docId']['duration']['p95'].to_s.match(/^\d{0,}/)}"; rescue; 0; end
  article_recs = begin; "#{data['com.wordnik.bifrost.apis.ArticlesApi']['/articles/recommendations']['duration']['mean'].to_s.match(/^\d{0,}/)} / #{data['com.wordnik.bifrost.apis.ArticlesApi']['/articles/recommendations']['duration']['p95'].to_s.match(/^\d{0,}/)}"; rescue; 0; end
  homescreen = begin; "#{data['com.wordnik.bifrost.apis.SettingsApi']['/homescreen']['duration']['mean'].to_s.match(/^\d{0,}/)} / #{data['com.wordnik.bifrost.apis.SettingsApi']['/homescreen']['duration']['p95'].to_s.match(/^\d{0,}/)} "; rescue; 0; end
  chirp = begin; "#{data['com.wordnik.bifrost.apis.AccountApi']['/account/chirpWithAuthSession']['duration']['mean'].to_s.match(/^\d{0,}/)} / #{data['com.wordnik.bifrost.apis.AccountApi']['/account/chirpWithAuthSession']['duration']['p95'].to_s.match(/^\d{0,}/)}"; rescue; 0; end
  profile = begin; "#{data['com.wordnik.bifrost.apis.UserProfileApi']['myProfile']['duration']['mean'].to_s.match(/^\d{0,}/)} / #{data['com.wordnik.bifrost.apis.UserProfileApi']['myProfile']['duration']['p95'].to_s.match(/^\d{0,}/)}"; rescue; 0; end
  collection = begin; "#{data['com.wordnik.bifrost.apis.CollectionsApi']['/collection/get-collection']['duration']['mean'].to_s.match(/^\d{0,}/)} / #{data['com.wordnik.bifrost.apis.CollectionsApi']['/collection/get-collection']['duration']['p95'].to_s.match(/^\d{0,}/)}"; rescue; 0; end
  user_collections = begin; "#{data['com.wordnik.bifrost.apis.CollectionsApi']['/collection/get-collections']['duration']['mean'].to_s.match(/^\d{0,}/)} / #{data['com.wordnik.bifrost.apis.CollectionsApi']['/collection/get-collections']['duration']['p95'].to_s.match(/^\d{0,}/)}"; rescue; 0; end
  collection_recs = begin; "#{data['com.wordnik.bifrost.apis.CollectionsApi']['/collection/recommendations']['duration']['mean'].to_s.match(/^\d{0,}/)} / #{data['com.wordnik.bifrost.apis.CollectionsApi']['/collection/recommendations']['duration']['p95'].to_s.match(/^\d{0,}/)}"; rescue; 0; end
  interest_stream = begin; "#{data['com.wordnik.bifrost.apis.InterestsApi']['/interests/stream']['duration']['mean'].to_s.match(/^\d{0,}/)} / #{data['com.wordnik.bifrost.apis.InterestsApi']['/interests/stream']['duration']['p95'].to_s.match(/^\d{0,}/)}"; rescue; 0; end
  interest_search = begin; "#{data['com.wordnik.bifrost.apis.InterestsApi']['/interests/search']['duration']['mean'].to_s.match(/^\d{0,}/)} / #{data['com.wordnik.bifrost.apis.InterestsApi']['/interests/search']['duration']['p95'].to_s.match(/^\d{0,}/)}"; rescue; 0; end
  login = begin; "#{data['com.wordnik.bifrost.apis.AccountApi']['/account/oauthLogin']['duration']['mean'].to_s.match(/^\d{0,}/)} / #{data['com.wordnik.bifrost.apis.AccountApi']['/account/oauthLogin']['duration']['p95'].to_s.match(/^\d{0,}/)} "; rescue; 0; end
  ohai = begin; "#{data['com.wordnik.bifrost.apis.AccountApi']['/account/ohai']['duration']['mean'].to_s.match(/^\d{0,}/)} / #{data['com.wordnik.bifrost.apis.AccountApi']['/account/ohai']['duration']['p95'].to_s.match(/^\d{0,}/)}"; rescue; 0; end

  puts "#{news_wordwall}\t|#{news_tiles}\t|#{me_wordwall}\t|#{me_tiles}\t|#{article}\t|#{article_recs}\t|".green+
       "#{homescreen}\t|#{chirp}\t|#{profile}\t|#{collection}\t|#{user_collections}\t\t|#{collection_recs}\t\t".green+
       "|#{interest_stream}\t\t|#{interest_search}\t\t|#{login}\t|#{ohai}".green

  sleep ARGV[1].to_i
end
