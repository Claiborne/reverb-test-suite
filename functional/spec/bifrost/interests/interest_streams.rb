require 'rspec'
require 'config_path'
require 'rest_client'
require 'json'
require 'bifrost/token.rb'
require 'bifrost/trending_helper.rb'

include Token

describe "INTERESTS - Get me interest" do

  before(:all) do
    # Get bifrost environment
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../../config/bifrost.yml"
    @bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

    # Set headers
    @headers = {:content_type => 'application/json', :accept => 'application/json'}

    # Get anon session token
    @session = get_anon_token @bifrost_env

    @interest = 'Cake'

    url = @bifrost_env+"/interests/stream/me?interest=#@interest&api_key="+@session
    begin
      response = RestClient.get url, @headers
    rescue => e
      raise StandardError.new(e.message+":\n"+url)
    end
    @data = JSON.parse response

  end

  include_examples "Trending Tiles Basic Checks"

  it "should return a 'known' value of 'false' for the interest" do
    @data.has_key?('known').should be_true
    @data['known'].should be_false
    @data['known'].to_s.should == 'false'
  end

  it "should return a 'shareUrl' value of '/share/interest/Cake' for the interest" do
    @data.has_key?('shareUrl').should be_true
    @data['shareUrl'].match("/share/interest/#@interest").should be_true
  end

  it "should return less than 5 exact dups for 'Cake'" do
    skip = 0
    limit = 24
    ids = []

    40.times do
      url = @bifrost_env+"/interests/stream/me?interest=#@interest&skip=#{skip}&api_key="+@session
      res = RestClient.get url, {:content_type => 'application/json', :accept => 'application/json'}
      data = JSON.parse res
      break if data['tiles'].count == 0
      skip = skip + data['tiles'].count
      data['tiles'].each do |d|
        ids << d['contentId']
      end
    end
    number_of_non_uniques = ids.length-ids.uniq.length
    number_of_non_uniques.should < 5
  end
end
