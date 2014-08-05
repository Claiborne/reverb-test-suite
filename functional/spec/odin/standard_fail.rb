require 'bunny'
require 'json'
require 'pp'
require 'rspec'
require 'securerandom'
require 'odin/odin_shared_examples.rb'
require 'odin/odin_spec_helper.rb'; include OdinSpecHelper

path_to_urls = File.dirname(__FILE__)+"/../../lib/odin/standard_fail.txt"
standard_fail_urls =  []

File.open(path_to_urls, "r") do |f|
  f.each_line do |line|
    standard_fail_urls << line.strip
  end
end

raise RuntimeError, "No standard fail URLs" if standard_fail_urls.length == 0

standard_fail_urls.each do |url|
describe "Article ingestion - successes", :standard_fail => true do

  before(:all) do

    tunnnel_odin_dev

    $counter = 0
    @timeout = 60

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

    include_examples 'Shared correlated and parsed'

    include_examples 'Shared filtered'

    include_examples 'Shared all'

    include_examples 'Debug'

  end

end; end