require 'bunny'
require 'json'
require 'pp'
require 'rspec'
require 'securerandom'
require 'odin/odin_shared_examples.rb'
require 'odin/odin_spec_helper.rb'; include OdinSpecHelper

describe "Article ingestion - 500 doc" do

  before(:all) do

    tunnnel_odin_bunny
    
    $counter = 0
    @timeout = 60

    @request_id = SecureRandom.uuid.to_s
    @url_submitted = 'https://stage-api.helloreverb.com/v2/trending/tiles/'
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

  context 'https://stage-api.helloreverb.com/v2/trending/tiles/' do 

    include_examples 'Submit'

    include_examples 'Shared failed'

    it "should fail because URI didn't expand to a 2xx statuscode" do
      failed_notification = extractNotification @odin_notifications, 'failed'
      failed_notification['failed']['errorMessage'].should == "URI didn't expand to a 2xx statuscode"
    end

    include_examples 'Shared all'

    include_examples 'Debug'

  end

end
