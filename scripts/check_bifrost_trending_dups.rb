require 'rest-client'
require 'json'
require 'rspec'
require File.dirname(__FILE__)+'/../functional/lib/bifrost/article_dup_checker.rb'; include ArticleDupChecker
require File.dirname(__FILE__)+'/../functional/lib/bifrost/token.rb'; include Token

if !Hash.method_defined? :slice
  class Hash
    def slice(*keys)
      {}.tap{ |h| keys.each{ |k| h[k]=self[k] if has_key?(k) } }
    end
  end
end

describe "Trending articles" do

  def articles_once(article_endpoint, key, skip)
      headers = {:content_type => 'application/json', :accept => 'application/json'}
      res = RestClient.get article_endpoint+"?skip=#{skip}&limit=24&api_key="+key, headers
      data = JSON.parse res
      data["tiles"]
    end
  
    def articles_recur(article_endpoint, key, skip, accum, calls, max_calls)
      return accum if calls > max_calls
      arts = articles_once(article_endpoint, key, skip)
      if arts.count == 0
        accum
      else
        articles_recur(article_endpoint, key, skip+arts.count, accum << arts, calls+1, max_calls)
      end
    end
  
    def articles(article_endpoint, key, max_calls = 21)
      # 21*24 = 504; articles typically only go out to 500
      articles_recur(article_endpoint, key, 0, [], 0, max_calls).flatten
    end
    
    
  def check_dups(article_endpoint, key)
    duplicates_or_near_duplicates(articles(article_endpoint, key))
  end

  def readable_output(duplicate_sets)
    less = duplicate_sets.map{ |s| 
      s.map{|art| art.slice("contentId", "shareUrl", "summary")}}
    JSON.pretty_generate(less)
  end
  
  def duplicate_error_message(context, duplicate_sets)
    "DUPLICATES: #{context} : There were #{duplicate_sets.size} sets of duplicates.\nThey were:\n#{readable_output(duplicate_sets)}"
  end

  before(:all) do
    ENV['env'] = 'prd'

    @domain = 'https://stage-api.helloreverb.com/v2'

    @anon_token = get_anon_token @domain
    @social_token = '6070006b495005cc287825b09883469fac9b40561f36fa64' #social_token = get_social_token @domain

  end

  
  it "should not return near duplicate articles in 'me'" do
     duplicate_sets = check_dups @domain+"/trending/tiles/me", @anon_token
     begin
       duplicate_sets.should == []
     rescue => e
       raise e, duplicate_error_message("Near duplicate articles in 'me'", duplicate_sets)
     end
   end
  
  it "should not return near duplicate articles in 'friends'" do
    duplicate_sets = check_dups @domain+"/trending/tiles/social", @social_token
    begin
      duplicate_sets.should == []
    rescue => e
      raise e, duplicate_error_message("Near duplicate articles in 'friends'", duplicate_sets)
    end
  end
  
  it "should not return any near duplicate articles in 'news'" do
     duplicate_sets = check_dups @domain+"/trending/tiles/global", @anon_token
     begin
       duplicate_sets.should == []
     rescue => e
       raise e, duplicate_error_message("Near duplicate articles in 'global'", duplicate_sets)
     end
   end
  
  it "should not return any exact duplicate articles (by content) in 'me'" do
     duplicate_sets = exact_duplicates(articles(@domain+"/trending/tiles/me", @anon_token))
     begin
       duplicate_sets.should == []
     rescue => e
       raise e, duplicate_error_message("Exact duplicate articles (by content) in 'me'", duplicate_sets)
     end
   end
  
  it "should not return any exact duplicate articles (by content) in 'friends'" do
    duplicate_sets = exact_duplicates(articles(@domain+"/trending/tiles/social", @social_token))
    begin
      duplicate_sets.should == []
    rescue => e
      raise e, duplicate_error_message("Exact duplicate articles (by content) in 'friends'", duplicate_sets)
    end
  end

  
  it "should not return exact content duplicate articles (by content) in 'global'" do
     duplicate_sets = exact_duplicates(articles(@domain+"/trending/tiles/global", @anon_token))
     begin
       duplicate_sets.should == []
     rescue => e
       raise e, duplicate_error_message("Exact duplicate articles (by content) in 'global'", duplicate_sets)
     end
   end


    it "should not return exact duplicate articles by contentId in 'me'" do
       duplicate_sets = exact_duplicates_by_content_id(articles(@domain+"/trending/tiles/me", @anon_token))
       begin
         duplicate_sets.should == []
       rescue => e
         raise e, duplicate_error_message("Exact duplicate articles (by contentId) in 'me'", duplicate_sets)
       end
     end
   
   it "should not return exact duplicate articles by contentId in 'friends'" do
      duplicate_sets = exact_duplicates_by_content_id(articles(@domain+"/trending/tiles/social", @social_token))
      begin
        duplicate_sets.should == []
      rescue => e
        raise e, duplicate_error_message("Exact duplicate articles (by contentId) in 'friends'", duplicate_sets)
      end
    end

    it "should not return exact duplicate articles by contentId in 'global'" do
       duplicate_sets = exact_duplicates_by_content_id(articles(@domain+"/trending/tiles/global", @anon_token))
       begin
         duplicate_sets.should == []
       rescue => e
         raise e, duplicate_error_message("Exact duplicate articles (by contentId) in 'global'", duplicate_sets)
       end
     end
   
  
end
