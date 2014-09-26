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

    tunnel_odin_bunny
    
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

    include_examples 'Shared correlated and parsed with filter'

    include_examples 'Shared correlated and parsed'

    it 'should return the same correlated.expandedUri value as submitted' do
      correlated = extractNotification @odin_notifications, 'correlated'
      correlated['correlated']['expandedUri'].should == @url_submitted
    end

    include_examples 'Shared standard success'

    include_examples 'Shared all'

    include_examples 'Debug'

  end

  context 'Get rendered doc using /rendered/document/docId' do

    before(:all) do

      sleep 7

      tunnel_odin

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

    include_examples 'Smoke doc rendering'

    it 'should return the correct guid' do
      @doc['guid'].should == 'http://odin-integration.helloreverb.com/smoke_articles/standard.html'
    end

    it 'should return the correct sourceUrl' do 
      @doc['sourceUrl'].should == 'http://odin-integration.helloreverb.com/smoke_articles/standard.html'
    end

    it 'should return the correct title' do
      @doc['title'].should == 'Standard'
    end

    %w(Technology Health).each do |topic| # note Health is optional: it's value is 0.099
      it "should return the topic '#{topic}'" do
        doc_topics = []
        @doc['topics']['topics'].each do |t|
          doc_topics << t['key']
        end
        doc_topics.should include topic
      end
    end

    ['Application software', 'Test-driven development', 'Source code', 'Computer programming', 'RSpec', 'User (computing)'].each do |concept|
      it "should return the concept '#{concept}'" do
        doc_concepts = []
        @doc['topics']['concepts'].each do |t|
          doc_concepts << t['key']
        end
        doc_concepts.should include concept
      end
    end

    it 'should return a cleanText string at least 3200 chars long' do
      @doc['cleanText'].length.should >= 3200
    end

    it 'should return the correct siteIcon value' do
      icon = 'http://g.etfv.co/http://odin-integration.helloreverb.com/smoke_articles/standard.html'
      @doc['siteIcon'].should == icon
      RestClient.get icon
    end

    it 'should return the correct siteName value' do
      @doc['siteName'].should == 'odin-integration.helloreverb.com'
    end

  end 

  context 'Get ingestion status by URL using /ingestion/status?url=url' do

    before(:all) do
      url = "http://localhost:8080/api/ingestion/status?url=#{@url_submitted}"
      begin
        response = RestClient.get url, :content_type => 'application/json', :accept => 'json'
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
      @doc = JSON.parse response
    end

    it 'should return the same workflowId as the request_id sent' do
      @doc['executionInfo']['execution']['workflowId'].should == @request_id
    end

    it 'should return at least one activity' do
      @doc['activities'].count.should > 0
    end

    it 'should return a close status of completed' do
      @doc['executionInfo']['closeStatus']['value'].should == 'Completed'
    end
  end

  context 'Get rendered features using /rendered/features/docId' do

    before(:all) do
      parsed_notification = extractNotification @odin_notifications, 'parsed'
      @doc_id = parsed_notification['parsed']['documentId']['docId'].to_s
      url = "http://localhost:8080/api/rendered/features/#@doc_id"
      begin
        response = RestClient.get url, :content_type => 'application/json', :accept => 'json'
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
      @doc = JSON.parse response
    end

    it 'should reutrn the correct docId' do
      @doc['docId'].should.to_s == @doc_id
    end

    it 'should return the same guid as submitted' do 

    end

    it 'should return the correct title' do
      @doc['title'].should == 'Standard'
    end

    %w(Technology Health).each do |topic| # note Health is optional: it's value is 0.099
      it "should return the topic '#{topic}'" do
        doc_topics = []
        @doc['docFeatures']['topics'].each do |t|
          doc_topics << t['key']
        end
        doc_topics.should include topic
      end
    end

    ['Application software', 'Test-driven development', 'Source code', 'Computer programming', 'RSpec', 'User (computing)'].each do |concept|
      it "should return the concept '#{concept}'" do
        doc_concepts = []
        @doc['docFeatures']['concepts'].each do |t|
          doc_concepts << t['key']
        end
        doc_concepts.should include concept
      end
    end

    it 'should return a siteId' do
      @doc['siteId'].class.to_s.should == 'String'
      @doc['siteId'].length.should > 0
    end

    it 'should return a non-blank tags array' do 
      @doc['tags'].length.should > 0
    end

    %w(site partner submitter).each do |tag|
      it "should incude the tag '#{tag}'" do 
        @doc['tags'].to_s.should match(tag)
      end
    end

    it 'should return a publishedDate' do
      @doc['publishedDate'].should match(/\d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ/)
    end

    %w(lemmapos namedent).each do |d|
      it "should return data for titleFeatures.#{d}" do
        @doc['titleFeatures'][d].length.should > 0
      end

      it "should return data for features.#{d}" do
        @doc['features'][d].length.should > 0
      end
    end
  end

  context 'Edit rendered doc' do

    before(:all) do
      parsed_notification = extractNotification @odin_notifications, 'parsed'
      @doc_id = parsed_notification['parsed']['documentId']['docId'].to_s
      url = "http://localhost:8080/api/transformation/document"
      @body = {
        :documentId => {
          :docId => @doc_id.to_i
        },
        :addConcepts => {
          :concepts => [
            {
              :feature => "Smartphone", # modified
              :value => 0.9
            }
          ]
        },
        :removeConcepts => { 
          :concepts  => ["RSpec"] # modified
        },
        :setTitle => {
          :title => "One two three" # modified
        },
        :setWebView => {
          :isWebView => false # modified
        }
      }
      begin
        response = RestClient.post url, @body.to_json, :content_type => 'application/json', :accept => 'json'
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
      @response_code = response.code

      sleep 10

      rendered_url = "http://localhost:8080/api/rendered/document/#@doc_id"
      begin
        rendered_response = RestClient.get rendered_url, :content_type => 'application/json', :accept => 'json'
      rescue => e
        raise StandardError.new(e.message+":\n"+rendered_url)
      end
      @doc = JSON.parse rendered_response

    end # end before all

    it 'should return a 200' do 
      @response_code.should == 200
    end

    xit 'should reflect adding a concept (FAILS: RVB-7576)' do 
      doc_concepts = []
      @doc['topics']['concepts'].each do |t|
        doc_concepts << t['key']
        if t['key'] == 'Smartphone'
          t['value'].should == 0.9
        end
      end
      doc_concepts.should include 'Smartphone'
    end

    xit 'should reflect removing a concept (FAILS: RVB-7576)' do 
      doc_concepts = []
      @doc['topics']['concepts'].each do |t|
        doc_concepts << t['key']
      end
      doc_concepts.should_not include 'RSpec'
    end

    it 'should reflect editing the title' do
      @doc['title'].should == 'One two three'
    end

    it 'should reflect editing clean vs webview' do
      @doc['isClean'].to_s.should == 'false'
    end

    it 'should reflect all changes when making a GET to /transformation/document/{docId}' do 
      get_transform_url = "http://localhost:8080/api/transformation/document/#@doc_id"
      begin
        get_transform_response = RestClient.get get_transform_url, :content_type => 'application/json', :accept => 'json'
      rescue => e
        raise StandardError.new(e.message+":\n"+get_transform_url)
      end
      doc = JSON.parse get_transform_response
      doc.to_s == @body.to_s
    end
  end

  context 'Document resubmission' do

    before(:all) do
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

      @ch.direct('online-messaging', :durable => true).publish(@message, :routing_key => 'global.urlSubmission')

      sleep 12

      parsed_notification = extractNotification @odin_notifications, 'parsed'
      @doc_id = parsed_notification['parsed']['documentId']['docId'].to_s

      url = "http://localhost:8080/api/rendered/document/#@doc_id"
      begin
        r = RestClient.get url, :content_type => 'application/json', :accept => 'json'
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
      @resubmitted_doc = JSON.parse r

    end # end before all

    after(:all) {@conn.close}

    it 'should retain edited title' do
      @resubmitted_doc['title'].should == 'One two three'
    end

    it 'should retain edited isClean' do
      @resubmitted_doc['isClean'].to_s.should == 'false'
    end

    xit 'should retain added concept (FAILS: RVB-7576)' do
      doc_concepts = []
      @resubmitted_doc['topics']['concepts'].each do |t|
        doc_concepts << t['key']
        if t['key'] == 'Smartphone'
          t['value'].should == 0.9
        end
      end
      doc_concepts.should include 'Smartphone'
    end

    xit 'should retain removed concept as removed (FAILS: RVB-7576)' do
      doc_concepts = []
      @resubmitted_doc['topics']['concepts'].each do |t|
        doc_concepts << t['key']
      end
      doc_concepts.should_not include 'RSpec'
    end

  end # end context

  context "Document deletion" do

    before(:all) do 
      parsed_notification = extractNotification @odin_notifications, 'parsed'
      @doc_id = parsed_notification['parsed']['documentId']['docId'].to_s
    end

    it 'should delete the document' do 
      url = "http://localhost:8080/api/rendered/document/#@doc_id"
      begin
        r = RestClient.delete url
      rescue => e
        raise StandardError.new(e.message+":\n"+url)
      end
      r.code.should == 200
      r.should == 'Document successfully removed'
      sleep 10
    end

    xit 'should return a 404 when requesting the deleted doc by ID (FAILS: RVB-7578)' do
      url = "http://localhost:8080/api/rendered/document/#@doc_id"
      expect {RestClient.get url}.to raise_error(RestClient::Unauthorized) 
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