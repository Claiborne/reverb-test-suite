require 'rest-client'
require 'json'
require 'rspec'
require File.dirname(__FILE__)+'/../functional/lib/bifrost/article_dup_checker.rb'; include ArticleDupChecker
require File.dirname(__FILE__)+'/../functional/lib/bifrost/token.rb'; include Token

describe "Trending articles" do

  def check_dups(article_endpoint, key)
    tiles = []
    duplicate_articles = []
    skip = 0
    2.times do 
      res = RestClient.get article_endpoint+"?skip=#{skip}&api_key="+key, @headers
      data = JSON.parse res
      data['tiles'].each do |tile|
        tiles << tile
      end
      duplicates_or_near_duplicates(tiles).each do |dup|
        duplicate_articles << dup[0]['contentId']
      end
      puts data['tiles'].count
    end
    duplicate_articles
  end

  before(:all) do
    ENV['env'] = 'prd'

    @domain = 'https://api.helloreverb.com/v2'

    @anon_token = get_anon_token @domain
    @social_token = social_token = get_social_token @domain

    @headers = {:content_type => 'application/json', :accept => 'application/json'}
  end

  it "should not return duplicate articles in 'me'" do
    duplicate_articles_returned = check_dups @domain+"/trending/tiles/me", @anon_token
    duplicate_articles_returned.should == []
  end

  it "should not return duplicate articles in 'friends'" do
    duplicate_articles_returned = check_dups @domain+"/trending/tiles/social", @social_token
    duplicate_articles_returned.should == []
  end

  it "should not return duplicate articles in 'news'" do
    duplicate_articles_returned = check_dups @domain+"/trending/tiles/global", @anon_token
    duplicate_articles_returned.should == []
  end
end
