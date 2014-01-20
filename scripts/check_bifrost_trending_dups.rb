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

  def return_readable_output(dup_articles)
    less = dup_articles.map{ |s| 
      s.map{|art| art.slice("contentId", "shareUrl", "summary")}}
    JSON.pretty_generate(less)
  end

  before(:all) do
    ENV['env'] = 'prd'

    @domain = 'https://api.helloreverb.com/v2'

    @anon_token = get_anon_token @domain
    @social_token = social_token = get_social_token @domain

  end

  
  it "should not return duplicate articles in 'me'" do
     duplicate_articles_returned = check_dups @domain+"/trending/tiles/me", @anon_token
     begin
       duplicate_articles_returned.should == []
     rescue => e
       raise e, "Duplicates returned:\n#{return_readable_output duplicate_articles_returned}"
     end
   end

  it "should not return duplicate articles in 'friends'" do
    duplicate_articles_returned = check_dups @domain+"/trending/tiles/social", @social_token
    begin
      duplicate_articles_returned.should == []
    rescue => e
      raise e, "Duplicates returned:\n#{return_readable_output duplicate_articles_returned}"
    end
  end

  it "should not return any exact duplicate articles in 'news'" do
     duplicate_articles_returned = check_dups @domain+"/trending/tiles/global", @anon_token
     begin
       duplicate_articles_returned.should == []
     rescue => e
       raise e, "Exact Duplicates returned:\n#{return_readable_output duplicate_articles_returned}"
     end
   end
 
  it "should not return any exact duplicate articles in 'me'" do
     duplicate_articles_returned = exact_duplicates(articles(@domain+"/trending/tiles/me", @anon_token))
     begin
       duplicate_articles_returned.should == []
     rescue => e
       raise e, "Exact Duplicates returned:\n#{return_readable_output duplicate_articles_returned}"
     end
   end

  it "should not return any exact duplicate articles in 'friends'" do
    duplicate_articles_returned = exact_duplicates(articles(@domain+"/trending/tiles/social", @social_token))
    begin
      duplicate_articles_returned.should == []
    rescue => e
      raise e, "Exact Duplicates returned:\n#{return_readable_output duplicate_articles_returned}"
    end
  end

  
  it "should not return duplicate articles in 'news'" do
     duplicate_articles_returned = exact_duplicates(articles(@domain+"/trending/tiles/global", @anon_token))
     begin
       duplicate_articles_returned.should == []
     rescue => e
       raise e, "Exact Duplicates returned:\n#{return_readable_output duplicate_articles_returned}"
     end
   end
   
  
end
