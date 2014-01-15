require 'rest-client'
require 'json'
require 'rspec'
require File.dirname(__FILE__)+'/../functional/lib/bifrost/article_dup_checker.rb'; include ArticleDupChecker
require File.dirname(__FILE__)+'/../functional/lib/bifrost/token.rb'; include Token

describe "Trending articles" do

  def articles_once(article_endpoint, key, skip)
    res = RestClient.get article_endpoint+"?skip=#{skip}&limit=24&api_key="+key, @headers
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
  
  def duplicates(articles) 
    duplicates_or_near_duplicates(articles).map{|dups| 
      dups.map{|d| 
          { "contentId" => d["contentId"], 
            "shareUrl" => d["shareUrl"],
            "summary" => d["summary"]
          }
        }
      }
  end
  
  
  before(:all) do
    ENV['env'] = 'prd'

    @domain = 'https://api.helloreverb.com/v2'

    @anon_token = get_anon_token @domain
    @social_token = social_token = get_social_token @domain

    @headers = {:content_type => 'application/json', :accept => 'application/json'}
    @empty_json = JSON.pretty_generate([])
    
  end

  it "should not return duplicate articles in 'me'" do
    duplicate_articles_returned = duplicates @domain+"/trending/tiles/me", @anon_token
    JSON.pretty_generate(duplicate_articles_returned).should == @empty_json
  end

  it "should not return duplicate articles in 'friends'" do
    duplicate_articles_returned = duplicates @domain+"/trending/tiles/social", @social_token
    JSON.pretty_generate(duplicate_articles_returned).should == @empty_json
  end

  it "should not return duplicate articles in 'news'" do
    duplicate_articles_returned = duplicates @domain+"/trending/tiles/global", @anon_token
    JSON.pretty_generate(duplicate_articles_returned).should == @empty_json
  end
end
