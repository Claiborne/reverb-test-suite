require 'bunny'
require 'json'
require 'pp'
require 'rspec'
require 'securerandom'
require 'odin/odin_shared_examples.rb'
require 'odin/odin_spec_helper.rb'; include OdinSpecHelper

describe "Article ingestion - smoke success", :smoke_success => true do

  before(:all) do

    tunnnel_odin_dev

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