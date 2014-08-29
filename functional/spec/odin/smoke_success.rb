require 'bunny'
require 'json'
require 'pp'
require 'rspec'
require 'securerandom'
require 'rest_client'
require 'odin/odin_shared_examples.rb'
require 'odin/odin_spec_helper.rb'; include OdinSpecHelper

describe "Article ingestion - smoke success", :smoke_success => true do

  before(:all) do

    tunnnel_odin_bunny
    
    $counter = 0
    @timeout = 60

    # correlated, parsed, docFilterOkay, docDedupOkay
    # mediaExtractionOkay, topicExtractionOkay, conceptExtractionOkay

    @request_id = SecureRandom.uuid.to_s
    @url_submitted = 'http://odin-integration.helloreverb.com/smoke_articles/standard.html'
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

  context 'http://odin-integration.helloreverb.com/smoke_articles/standard.html' do

    include_examples 'Submit'

    include_examples 'Shared correlated and parsed'

    it 'should return the same correlated.expandedUri value as submitted' do
      correlated = extractNotification @odin_notifications, 'correlated'
      correlated['correlated']['expandedUri'].should == @url_submitted
    end

    include_examples 'Shared standard success'

    include_examples 'Shared all'

    include_examples 'Debug'

  end

  context 'Doc rendering' do

    before(:all) do
      parsed_notification = extractNotification @odin_notifications, 'parsed'
      @doc_id = parsed_notification['parsed']['documentId']['docId'].to_s
      url = "http://localhost:8080/api/rendered/document/#{@doc_id}?format=json"
      begin
        @response = RestClient.get url, :content_type => 'application/json'
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
      @doc = JSON.parse @response
    end

    it 'should a 200 code when requesting /api/rendered/document/ID' do      
      @response.code.should == 200
    end

    %w(docId guid sourceUrl publishDate title authors topics articleMedia 
      cleanText isClean isLicensed summary siteIcon siteName siteId).each do |key|
      it "should return a #{key} key" do
        @doc[key].should be_true
      end
    end

    it 'should return the correct doc id' do
      @doc['docId'].to_s.should == @doc_id.to_s
    end

    it 'should return the correct guid' do
      @doc['guid'].should == 'http://odin-integration.helloreverb.com/smoke_articles/standard.html'
    end

    it 'should return the correct sourceUrl' do 
      @doc['sourceUrl'].should == 'http://odin-integration.helloreverb.com/smoke_articles/standard.html'
    end

    it 'should return a publishDate' do
      @doc['publishDate'].should match(/\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\dZ/)
    end

    it 'should return the correct title' do
      @doc['title'].should == 'Standard'
    end

    %w(Technology ofj Health).each do |topic|
      it "should return the topic '#{topic}'" do
        doc_topics = []
        @doc['topics']['topics'].each do |t|
          doc_topics << t['key']
        end
        doc_topics.should include topic
      end
    end

  end # end context
end # end describe 

# https://wordnik.jira.com/wiki/display/DEV/Integration+Test+Specification

# Receiving IngestionNotification messages from Odin:
# create a queue with the name global.urlIngestionResult.itd-service
# create a binding from the exchange online-messaging and the routing key global.urlIngestionResult
# create a consumer for the queue

# http://rubybunny.info/articles/getting_started.html

=begin

ssh -f -N -L 5672:localhost:5672 54.219.86.212
ssh -f -N -L 15672:localhost:15672 54.219.86.212

ps aux | grep rabbitmq

ln -sfv /usr/local/opt/rabbitmq/*.plist ~/Library/LaunchAgents
ps aux | grep ssh

Receiving IngestionNotification messages from Odin through RabbitMQ is a little more complicated. 
ITD needs to create a queue with the name global.urlIngestionResult.itd-service and create a 
binding from the exchange online-messaging and the routing key global.urlIngestionResult. 
The last step is to create a consumer for the queue. The schema of these message is outline 
in the database model section.

=end