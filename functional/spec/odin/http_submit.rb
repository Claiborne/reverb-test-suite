require 'bunny'
require 'json'
require 'pp'
require 'rspec'
require 'securerandom'
require 'rest_client'
require 'odin/odin_shared_examples.rb'
require 'odin/odin_spec_helper.rb'; include OdinSpecHelper

describe "Article ingestion - create workflow via HTTP" do

  before(:all) do
    
    tunnel_odin
    tunnel_odin_bunny

    $counter = 0
    @timeout = 60

    @request_id = SecureRandom.uuid.to_s

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

    @request_id = SecureRandom.uuid.to_s
    http_submit_url = "http://localhost:8080/api/corpus/submitUri"
    @url_submitted = 'http://odin-integration.helloreverb.com/smoke_articles/http_submit.html'
    @body = {
      "requestId" => @request_id,
      "url" => @url_submitted,
      "source" => "ReverbTestSuite",
      "eventName"=>"com.reverb.events.odin.package$Submission"
    }.to_json

    response = RestClient.post http_submit_url, @body, :content_type => 'application/json', :accept => 'json'
    @data = JSON.parse response

  end

  after(:all) {@conn.close}

  context 'HTTP submission' do
    it 'should be successful' do
      puts @request_id
      @data.should == {'success'=>{'value'=>true}}
    end
  end

  context 'http://odin-integration.helloreverb.com/smoke_articles/http_submit.html' do

    include_examples 'Shared correlated and parsed'

    it 'should return the same correlated.expandedUri value as submitted' do
      correlated = extractNotification @odin_notifications, 'correlated'
      correlated['correlated']['expandedUri'].should == @url_submitted
    end

    include_examples 'Shared standard success'

    include_examples 'Shared all'

    include_examples 'Debug'

  end

  context 'Doc rendering', :doc_render => true do

    before(:all) do

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

  end
end 
