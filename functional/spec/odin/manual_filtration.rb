require 'bunny'
require 'json'
require 'pp'
require 'rest_client'
require 'rspec'
require 'colorize'
require 'securerandom'
require 'odin/odin_shared_examples.rb'
require 'odin/odin_spec_helper.rb'; include OdinSpecHelper


filtered_urls = ['http://www.christianitytoday.com/ct/2014/july-august/craftsmanship-manual-labor.html',
'http://blogs.christianpost.com/already-am/10-reasons-daddys-should-date-their-daughters-22342/']

raise RuntimeError, "No filtered URLs" if filtered_urls.length == 0

filtered_urls.each do |url|
describe "Article ingestion - block list", :block_list => true do

  before(:all) do

    tunnel_odin

    begin
      # Block an exact domain
      RestClient.post "http://localhost:8080/api/filtration/insert", {"domain"=>"domain://www.christianitytoday.com","source"=>"Other","filtrationType"=>"ExactDomain", "message"=>""}.to_json, :content_type => :json, :accept => :json
      # Block a sub domain
      RestClient.post "http://localhost:8080/api/filtration/insert", {"domain"=>"domain://blogs.christianpost.com","source"=>"Other","filtrationType"=>"SubDomain", "message"=>""}.to_json, :content_type => :json, :accept => :json
      sleep 10 
    rescue => e
      puts "WARNING: An error occured when trying to use the filtration/insert endpoint: #{e.message}".yellow
    end

    tunnel_odin_bunny
    
    $counter = 0
    @timeout = 60*3

    @request_id = SecureRandom.uuid.to_s
    @url_submitted = url
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

  context url do

    include_examples 'Submit'

    include_examples 'Shared filtered without correlated and parsed'

    include_examples 'Shared all'

    it 'should filter because of uri' do
      filtered_notification = extractNotification @odin_notifications, 'filtered'
      filtered_notification['filtered']['reasons'][0]['rule']['name'].should == 'Uri'
    end

    it 'should only recieve one notification' do
      sleep 5
      @odin_notifications.length.should == 1
    end

    include_examples 'Debug'

  end

end; end