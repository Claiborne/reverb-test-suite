require 'bunny'
require 'json'
require 'pp'
require 'rspec'
require 'securerandom'
require 'odin/odin_shared_examples.rb'
require 'odin/odin_spec_helper.rb'; include OdinSpecHelper

describe "Article ingestion - duplicate" do

  class OdinDocHelper
    class << self; attr_accessor :doc; end
  end

  context 'submit original document' do

    before(:all) do

      #todo fix
      @timeout = 15
      @notification_count_break = 7

      @request_id = SecureRandom.uuid.to_s
      @url_submitted = 'http://odin-integration.helloreverb.com/smoke_articles/original_duplicate.html'
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

    include_examples 'Shared all'

    include_examples 'Shared standard success'

    it 'should get parsed.documentId.docId' do
      parsed = extractNotification @odin_notifications, 'parsed'
      OdinDocHelper.doc = parsed['parsed']['documentId']['docId']
    end

  end # end context

  context 'submit duplicate document' do

    before(:all) do

      @request_id = SecureRandom.uuid.to_s
      @url_submitted = 'http://odin-integration.helloreverb.com/smoke_articles/duplicate.html'
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

    include_examples 'Shared all'

    include_examples 'Shared filtered'

  end # end context

  context 'submit original document again' do

    before(:all) do

      @request_id = SecureRandom.uuid.to_s
      @url_submitted = 'http://odin-integration.helloreverb.com/smoke_articles/original_duplicate.html'
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

    include_examples 'Shared all'

    include_examples 'Shared standard success'

    it 'should return the same parsed.documentId.docId for a previously ingested URL' do
      parsed = extractNotification @odin_notifications, 'parsed'
      parsed['parsed']['documentId']['docId'].should == OdinDocHelper.doc
    end
  end # end context
end # end describe 
