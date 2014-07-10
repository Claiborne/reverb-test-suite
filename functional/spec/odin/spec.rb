require 'bunny'
require 'json'
require 'pp'
require 'rspec'

urls = {
  'new article' => 'http://blogs.reuters.com/breakingviews/2014/06/13/review-house-of-debt-diagnosis-beats-remedies/',
  #'404 article' => 'http://www.ign.com/404',
  #'500 article' => 'https://api.helloreverb.com/v2/trending/interests/me/qa_needs_a_500_example',
  #'301 article' => 'http://uk.ign.com/articles/2014/07/07/googles-3d-mapping-phones-to-help-robots-on-the-international-space-station',
  #'a homepage' => 'http://www.ign.com',
  
  }

module OdinSpecHelper
  def extractNotification(notifications, notification)
    notifications.each do |n|
      return n if n[notification]
    end
  end
end

shared_examples 'Shared all' do

  it 'should submit article to Odin' do
    @ch.direct('online-messaging', :durable => true).publish(@message, :routing_key => 'global.urlSubmission')
  end

  it "should recieve a notification from Odin" do
    timeout = 40
    notification_count_break = 6
    timeout.times do 
      break if @odin_notifications.count > notification_count_break
      sleep 1
    end
    @odin_notifications.length.should > 0
    # debug code todo delete:
    @odin_notifications.each do |odin_notification|
      puts odin_notification 
      puts ''
    end
  end

  it 'should recive only IngestionNotifications' do
    errors = []
    event_name = 'com.reverb.odin.model.IngestionNotification'
    @odin_notifications.each do |odin_notification|
      begin
        odin_notification['eventName'].should == event_name
      rescue
        errors << "Expected the following Odin notification to contain eventName of #{event_name}:\n"+odin_notification+"\n"
      end
    end
    errors.count.should == 0
  end

  it 'should recieve only notifications with a valid requestId' do
    errors = []
    @odin_notifications.each do |odin_notification|
      begin
        odin_notification['requestId'].should == @request_id
      rescue
        errors << "Expected the following Odin notification to contain requestId of #@request_id:\n"+odin_notification+"\n"
      end
    end
    errors.count.should == 0
  end
end

shared_examples 'Shared 200' do

end

urls.each do |x,y|
  describe "Article ingestion - #{x}" do

    include OdinSpecHelper

    before(:all) do

      @request_id = Random.rand(100**10).to_s
      @url_submitted = y
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

    %w(correlated parsed docFilterOkay docDedupOkay mediaExtractionOkay topicExtractionOkay conceptExtractionOkay).each do |notification_name|
      it "should recieve a #{notification_name} notification" do
        notification = extractNotification @odin_notifications, notification_name
        notification.should be_true
      end
    end

    it 'should recieve these notifications in order: correlated parsed docFilterOkay docDedupOkay' do
      expected_notifications = %w(correlated parsed docFilterOkay docDedupOkay)
      @odin_notifications.each_with_index do |notification, index|
        break if index >= expected_notifications.count
        notification[expected_notifications[index]].should be_true
      end
    end

    it 'should return the same correlated.originalUri value as submitted' do
      correlated = extractNotification @odin_notifications, 'correlated'
      correlated['correlated']['originalUri'].should == @url_submitted
    end

    it 'should return the same correlated.expandedUri value as submitted' do
      correlated = extractNotification @odin_notifications, 'correlated'
      correlated['correlated']['expandedUri'].should == @url_submitted
    end

    # specific to submitting a 301
    it 'should return the apporpriate correlated.originalUri and correlated.expandedUri when originalUri 301s' do
      correlated = extractNotification @odin_notifications, 'correlated'
      correlated['correlated']['originalUri'].should == @url_submitted
      correlated['correlated']['expandedUri'].should == 'http://www.ign.com/articles/2014/07/07/googles-3d-mapping-phones-to-help-robots-on-the-international-space-station'
    end

    it 'should return a valid correlated.siteId value' do
      correlated = extractNotification @odin_notifications, 'correlated'
      correlated['correlated']['siteId']['value'].class.to_s.should == 'Fixnum'
      correlated['correlated']['siteId']['value'].to_s.match(/^[0-9]/).should be_true
      correlated['correlated']['siteId']['value'].to_s.downcase.match(/[a-z]/).should be_false
    end

    it 'should return a valid parsed.documentId value' do
      parsed = extractNotification @odin_notifications, 'parsed'
      parsed['parsed']['documentId']['docId'].class.to_s.should == 'Fixnum'
      parsed['parsed']['documentId']['docId'].to_s.match(/^[0-9]/).should be_true
      parsed['parsed']['documentId']['docId'].to_s.downcase.match(/[a-z]/).should be_false
    end

    # specific to resubmitting same URL
    it 'should return the same parsed.documentId.docId for a previously ingested URL' do
      parsed = extractNotification @odin_notifications, 'parsed'
      parsed['parsed']['documentId']['docId'].should == 35392
    end

    %w(docDedupOkay mediaExtractionOkay topicExtractionOkay conceptExtractionOkay).each do |notification_name|
      it "should return a #{notification_name}.value of true" do
        notification = extractNotification @odin_notifications, notification_name
        notification[notification_name]['value'].should == true
      end
    end

  end # end describe 
end # end iteration of describe


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