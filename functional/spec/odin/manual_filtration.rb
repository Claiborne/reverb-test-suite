require 'bunny'
require 'json'
require 'pp'
require 'rest_client'
require 'rspec'
require 'colorize'
require 'securerandom'
require 'odin/odin_shared_examples.rb'
require 'odin/odin_spec_helper.rb'; include OdinSpecHelper

filtered_urls = [
  {:domain => 'www.christianitytoday.com', :url => 'http://www.christianitytoday.com/ct/2014/july-august/craftsmanship-manual-labor.html', :filtration_type => 'ExactDomain'},
  {:domain => 'blogs.christianpost.com', :url => 'http://blogs.christianpost.com/already-am/10-reasons-daddys-should-date-their-daughters-22342/', :filtration_type => 'SubDomain'}
]

remove_url = filtered_urls[0]

raise RuntimeError, "No filtered URLs" if filtered_urls.length == 0

filtered_urls.each do |filtered_url|
describe "Article ingestion - add to block list", :block_list => true do

  before(:all) do

    tunnel_odin

    domain = filtered_url[:domain]
    filtration_type = filtered_url[:filtration_type]

    begin
      RestClient.post "http://localhost:8080/api/filtration/insert", {"domain"=>"domain://#{domain}","source"=>"Other","filtrationType"=>"#{filtration_type}", "message"=>""}.to_json, :content_type => :json, :accept => :json
      sleep 10 
    rescue => e
      puts "WARNING: An error occured when trying to use the filtration/insert endpoint: #{e.message}".yellow
    end

    tunnel_odin_bunny
    
    $counter = 0
    @timeout = 60*3

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

    @message = {
      "eventName" => 'com.reverb.events.odin.package$Submission',
      "requestId" => @request_id,
      "url" => filtered_url[:url],
      "source" => "ReverbTestSuite"
    }.to_json
  end

  after(:all) {@conn.close}

  context filtered_url[:url] do

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

describe "Article ingestion - remove from block list", :block_list => true do

  before(:all) do

    tunnel_odin

    domain = remove_url[:domain]

    begin
      RestClient.post "http://localhost:8080/api/filtration/delete", {"domain"=>"domain://#{domain}"}.to_json, :content_type => :json, :accept => :json
      sleep 10 
    rescue => e
      puts "WARNING: An error occured when trying to use the filtration/delete endpoint: #{e.message}".yellow
    end

    tunnel_odin_bunny
    
    $counter = 0
    @timeout = 60*3

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

    @message = {
      "eventName" => 'com.reverb.events.odin.package$Submission',
      "requestId" => @request_id,
      "url" => remove_url[:url],
      "source" => "ReverbTestSuite"
    }.to_json
  end

  after(:all) {@conn.close}

  context remove_url[:url] do

    include_examples 'Submit'

    include_examples 'Shared correlated and parsed without filter'

    include_examples 'Debug'

  end

end
