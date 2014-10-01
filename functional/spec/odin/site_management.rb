require 'bunny'
require 'json'
require 'pp'
require 'rspec'
require 'securerandom'
require 'rest_client'
require 'odin/odin_shared_examples.rb'
require 'odin/odin_spec_helper.rb'; include OdinSpecHelper

describe "Site Management API", :test => true do

  before(:all) do

    tunnel_odin_bunny
    
    $counter = 0
    @timeout = 60

    # correlated, parsed, docFilterOkay, docDedupOkay
    # mediaExtractionOkay, topicExtractionOkay, conceptExtractionOkay

    @request_id = SecureRandom.uuid.to_s
    @url_submitted = 'http://blog.helloreverb.com/love-reverb-here-are-four-more-ways-to-share-the-reverb-love/'
    @odin_notifications = []

    @conn = Bunny.new(:host => "localhost", :port => 5672)

    @conn.start
    @ch = @conn.create_channel
    q = @ch.queue('', :exclusive => true)
    q.bind('online-messaging', :routing_key => 'global.urlIngestionResult')
      q.subscribe(:ack => true) do |delivery_info, properties, payload|
      odin_notification = JSON.parse payload
      @odin_notifications << odin_notification if odin_notification['requestId'] == @request_id
    end

    @message = {
      "eventName" => 'com.reverb.events.odin.package$Submission',
      "requestId" => @request_id,
      "url" => @url_submitted,
      "source" => "ReverbTestSuite"
    }.to_json
  end

  after(:all) {@conn.close}

  context 'Submit doc via Bunny' do

    include_examples 'Submit'

    include_examples 'Shared correlated and parsed with filter'

    include_examples 'Debug'

    sleep 2

  end

  context 'Search for the new site' do

    before(:all) do 
      url = "http://localhost:8080/api/site/search?searchString=helloreverb"
      begin
        r = RestClient.get url, :content_type => 'application/json', :accept => 'json'
      rescue => e 
        raise StandardError.new(e.message+":\n"+url)
      end
      site_search_data = JSON.parse r
      @sites = []
      @site = {}
      site_search_data.each do |s|
        @sites << s['name']
        @site = s if s['name'] == 'blog.helloreverb.com'
      end
    end

    it 'shoudld appear in search' do
      @sites.should include 'blog.helloreverb.com'
    end

    it 'should default isAlwaysWebView value to false' do
      @site['isAlwaysWebView'].to_s.should == 'false'
    end

    it 'should return a siteId value' do
      site_id = @site['siteId']['value']
      site_id.to_s.length.should > 0
      site_id.class.to_s.should == 'Fixnum'
    end
  end

  context 'Update a site' do

    before(:all) do
      @update_site_body = {
        :domain => 'domain://blog.helloreverb.com',
        :recommended => false,
        :recommendationSource => {
          :value => 'Default'
        },
        :isAlwaysWebView => true,
        :twitterHandle => '@Reverb',
        :name => 'Hello Reverb Blog',
        :nameSource => {
          :value => 'Default'
        }
      }
    end

    xit 'should post the update FAILS RVB-7666' do 
      url = "http://localhost:8080/api/site/update"
      begin
        r = RestClient.post url, @update_site_body.to_json, :content_type => 'application/json', :accept => 'json'
      rescue => e 
        raise StandardError.new(e.message+":\n"+url)
      end
      puts r
    end

  end

end 



