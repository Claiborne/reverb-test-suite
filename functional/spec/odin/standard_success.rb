require 'bunny'
require 'json'
require 'pp'
require 'rspec'
require 'securerandom'
require 'odin/odin_shared_examples.rb'
require 'odin/odin_spec_helper.rb'; include OdinSpecHelper

path_to_urls = File.dirname(__FILE__)+"/../../lib/odin/standard_success.txt"
standard_success_urls =  []

File.open(path_to_urls, "r") do |f|
  f.each_line do |line|
    standard_success_urls << line.strip
  end
end

raise RuntimeError, "No standard success URLs" if standard_success_urls.length == 0

standard_success_urls.each do |url|
describe "Article ingestion - successes", :standard_success => true do

  before(:all) do

    tunnel_odin_bunny
    
    $counter = 0
    @timeout = 60*3

    # correlated, parsed, docFilterOkay, docDedupOkay
    # mediaExtractionOkay, topicExtractionOkay, conceptExtractionOkay

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

    include_examples 'Shared correlated and parsed without filter'

    include_examples 'Shared correlated and parsed'

    include_examples 'Shared standard success'

    include_examples 'Shared all'

    include_examples 'Debug'

  end

  context 'Doc rendering', :doc_render => true do

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

  end

end; end