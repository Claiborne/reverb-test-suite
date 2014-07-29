require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'colorize'
require 'bifrost/read_article.rb'

describe "CONCEPT LISTS - Black-listed Concepts", :concept_lists => true do

  include Token
  include ReadArticle

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session_token = get_anon_token(@bifrost_env)

    @black_listed_word = 'Rape'
  end

  it 'should not appear as a tile when searched for' do
    blocked_interest = @black_listed_word
    url = @bifrost_env+"/interests/search/#{blocked_interest}?limit=10&api_key="+@session_token
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    data = JSON.parse response
    search_results = []
    data['results'].each do |result|
      search_results << result['value']
    end
    search_results.include?(blocked_interest).should be_false
  end

  it 'should be excluded from me tiles if an article with a blacklisted concept it read', :strict => true do
    case ENV['env']
    when 'prd'
      article_data = {:article_id => '63255202', :blacklisted => '' }
    when 'stg'
      article_data = {:article_id => '43988905', :blacklisted => '' }
    when 'dev'
      article_data = {:article_id => '2872151', :blacklisted => '' }
    else
      raise StandardError, 'No compatable env for this test group'
    end

    event_url = "#{@bifrost_env}/events/click?deviceId=reverb-test-suite&api_key=#{@session_token}"

    RestClient.post event_url, read_article(Time.now.utc.to_i-30, article_data[:article_id]), 'Content-Type' => 'application/json'
    sleep 5
    RestClient.post event_url, exit_article(Time.now.utc.to_i-30), 'Content-Type' => 'application/json' 
    sleep 2

    me_inferred_concepts = []

    [0,24].each do |skip|
      me_tiles_url = @bifrost_env+"/trending/tiles/me?skip=#{skip}&api_key="+@session_token
      begin
        me_tiles_response = RestClient.get me_tiles_url, @headers
      rescue => e
        raise StandardError.new(e.message+":\n"+me_tiles_url)
      end
      me_tiles = JSON.parse me_tiles_response

      me_tiles['tiles'].each do |me_tile|
        me_inferred_concepts << me_tile['contentId'] if me_tile['tileType'] == 'interest'
      end
    end

    me_inferred_concepts.each do |me_inferred_concept|
      me_inferred_concept.downcase.match(/prostitution/).should be_false
    end
  end

  it 'should be excluded from me interests if an article with a blacklisted concept it read' do
    me_interests_url = @bifrost_env+"/trending/interests/me?api_key="+@session_token
    begin
      me_interests_response = RestClient.get me_interests_url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+me_interests_url)
    end
    me_interests = JSON.parse me_interests_response
    me_inferred_concepts = []
    me_interests['interests'].each do |me_interest|
      me_inferred_concepts << me_interest['value']
    end
    me_inferred_concepts.each do |me_inferred_concept|
      me_inferred_concept.downcase.match(/prostitution/).should be_false
    end
  end


  it 'should not return a black-listed concept tiles in interest streams' do
    interest_tiles = []
    %w(0 24 48 60).each do |skip|
      url = "https://api.helloreverb.com/v2/interests/stream/me?skip=#{skip}&interest=Pejorative&api_key=cd497bc3a6702a04d53438fe5a174fa8827bb9010ab22a6c"
      begin
        response = RestClient.get url, @headers
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
      data = JSON.parse response
      data['tiles'].each do |tile|
        interest_tiles << tile['contentId'] if tile['tileType'] == 'interest'
      end
    end # end for each loop
    interest_tiles.count.should > 3
    interest_tiles.should_not include 'Nigger'
  end

end
