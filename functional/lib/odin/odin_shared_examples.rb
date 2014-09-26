# TOC
# Odin Submit
# Odin Doc Rendering


# Odin Submit

shared_examples 'Submit' do

  it 'should submit article to Odin' do
    @ch.direct('online-messaging', :durable => true).publish(@message, :routing_key => 'global.urlSubmission')
  end

end

shared_examples 'Shared correlated and parsed without filter' do
  %w(correlated parsed).each do |notification_name|
    it "should recieve a #{notification_name} notification" do
      @timeout.times do 
        raise 'Doc was filtered' if extractNotification @odin_notifications, 'filtered'
        raise 'Doc submission failed' if extractNotification @odin_notifications, 'failed'
        notification = extractNotification @odin_notifications, notification_name
        begin
          notification.should be_true
          break
        rescue
          sleep 1
          $counter += 1
          notification.should be_true if $counter >= @timeout
          next
        end 
      end # end timeout iteration
    end # end it
  end
end

shared_examples 'Shared correlated and parsed with filter' do
  %w(correlated parsed).each do |notification_name|
    it "should recieve a #{notification_name} notification" do
      @timeout.times do 
        raise 'Doc submission failed' if extractNotification @odin_notifications, 'failed'
        notification = extractNotification @odin_notifications, notification_name
        begin
          notification.should be_true
          break
        rescue
          sleep 1
          $counter += 1
          notification.should be_true if $counter >= @timeout
          next
        end 
      end # end timeout iteration
    end # end it
  end
end
  
shared_examples 'Shared correlated and parsed' do
  it 'should return the same correlated.originalUri value as submitted' do
    correlated = extractNotification @odin_notifications, 'correlated'
    correlated_url = correlated['correlated']['originalUri']
    correlated_url.should == @url_submitted
  end

  it 'should return a non-nil, non-blank correlated.expandedUri value' do
    correlated = extractNotification @odin_notifications, 'correlated'
    expanded_uri = correlated['correlated']['expandedUri']
    expanded_uri.should_not be_nil
    expanded_uri.delete("^a-zA-Z").length.should > 0
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
end

shared_examples 'Shared filtered' do

  %w(filtered).each do |notification_name|
    it "should recieve a #{notification_name} notification" do
      @timeout.times do 
        notification = extractNotification @odin_notifications, notification_name
        begin
          notification.should be_true
          break
        rescue
          sleep 1
          $counter += 1
          notification.should be_true if $counter >= @timeout
          next
        end 
      end # end timeout iteration
    end
  end

  it 'should recieve these notifications in order: correlated parsed filtered' do
    expected_notifications = %w(correlated parsed filtered)
    @odin_notifications.each_with_index do |notification, index|
      break if index >= expected_notifications.count
      notification[expected_notifications[index]].should be_true
    end
  end
end

shared_examples 'Shared filtered without correlated and parsed' do

  %w(filtered).each do |notification_name|
    it "should recieve a #{notification_name} notification" do
      @timeout.times do 
        notification = extractNotification @odin_notifications, notification_name
        begin
          notification.should be_true
          break
        rescue
          sleep 1
          $counter += 1
          notification.should be_true if $counter >= @timeout
          next
        end 
      end # end timeout iteration
    end
  end
end

shared_examples 'Shared filtered with docFilterOkay' do

  %w(filtered docFilterOkay).each do |notification_name|
    it "should recieve a #{notification_name} notification" do
      @timeout.times do 
        raise 'Doc submission failed' if extractNotification @odin_notifications, 'failed'
        notification = extractNotification @odin_notifications, notification_name
        begin
          notification.should be_true
          break
        rescue
          sleep 1
          $counter += 1
          notification.should be_true if $counter >= @timeout
          next
        end 
      end # end timeout iteration
    end
  end

  it 'should recieve these notifications in order: correlated parsed docFilterOkay filtered' do
    expected_notifications = %w(correlated parsed docFilterOkay filtered)
    @odin_notifications.each_with_index do |notification, index|
      break if index >= expected_notifications.count
      notification[expected_notifications[index]].should be_true
    end
  end
end

shared_examples 'Shared failed' do

  %w(failed).each do |notification_name|
    it "should recieve a #{notification_name} notification" do
      @timeout.times do 
        raise 'Doc submission filtered' if extractNotification @odin_notifications, 'filtered'
        notification = extractNotification @odin_notifications, notification_name
        begin
          notification.should be_true
          break
        rescue
          sleep 1
          $counter += 1
          notification.should be_true if $counter >= @timeout
          next
        end 
      end # end timeout iteration
    end
  end

  it 'should not recieve these notifications: correlated, parsed, filtered, docFilterOkay, docDedupOkay, mediaExtractionOkay, topicExtractionOkay, nlpPipelineOkay, conceptExtractionOkay' do
    %w(correlated parsed filtered docFilterOkay docDedupOkay mediaExtractionOkay topicExtractionOkay nlpPipelineOkay conceptExtractionOkay).each do |notification_name|
      notification = extractNotification @odin_notifications, notification_name
      notification.should be_nil
    end
  end
end

shared_examples 'Shared standard success' do

  %w(docFilterOkay docDedupOkay mediaExtractionOkay topicExtractionOkay nlpPipelineOkay conceptExtractionOkay).each do |notification_name|
    it "should recieve a #{notification_name} notification" do
      @timeout.times do 
        raise 'Doc was filtered' if extractNotification @odin_notifications, 'filtered'
        raise 'Doc submission failed' if extractNotification @odin_notifications, 'failed'
        notification = extractNotification @odin_notifications, notification_name
        begin
          notification.should be_true
          break
        rescue
          sleep 1
          $counter += 1
          notification.should be_true if $counter >= @timeout
          next
        end 
      end # end timeout iteration
    end
  end

  it 'should recieve these notifications in order: correlated parsed docFilterOkay docDedupOkay' do
    expected_notifications = %w(correlated parsed docFilterOkay docDedupOkay)
    @odin_notifications.each_with_index do |notification, index|
      break if index >= expected_notifications.count
      notification[expected_notifications[index]].should be_true, "Expected:\ncorrelated parsed docDedupOkay docFilterOkay\nGot:\n#{@odin_notifications}"
    end
  end

  %w(docDedupOkay mediaExtractionOkay topicExtractionOkay nlpPipelineOkay conceptExtractionOkay).each do |notification_name|
    it "should return a #{notification_name}.value of true" do
      notification = extractNotification @odin_notifications, notification_name
      notification[notification_name]['value'].should == true
    end
  end

  it 'should not recieve these notifications: failed, filtered' do
    %w(failed filtered).each do |notification_name|
      notification = extractNotification @odin_notifications, notification_name
      notification.should be_nil
    end
  end

end

shared_examples 'Shared all' do

  it 'should recive only IngestionNotifications' do
    errors = []
    event_name = 'com.reverb.events.odin.IngestionNotification'
    @odin_notifications.each do |odin_notification|
      begin
        odin_notification['eventName'].should == event_name
      rescue
        errors << "Expected the following Odin notification to contain eventName of #{event_name}:\n"+odin_notification.to_s+"\n"
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
        errors << "Expected the following Odin notification to contain requestId of #@request_id:\n"+odin_notification.to_s+"\n"
      end
    end
    errors.count.should == 0
  end
end

shared_examples 'Debug' do
  it 'should puts debug above', :debug => true do
    puts @odin_notifications
  end
end

# Odin Doc Rendering

shared_examples 'Smoke doc rendering' do

  it 'should a 200 code when requesting /api/rendered/document/ID' do      
    @response.code.should == 200
  end

  %w(docId guid sourceUrl publishDate title authors topics articleMedia 
    cleanText isClean isLicensed summary siteIcon siteName siteId).each do |key|
    it "should return a #{key} key" do
      @doc.has_key?(key).should be_true
    end
  end

  it 'should return the correct doc id' do
   @doc['docId'].to_s.should == @doc_id.to_s
  end

  it 'should return a non-nil, non-blank guid' do
    @doc['guid'].class.to_s.should == 'String'
    @doc['guid'].length.should > 0
  end

  it 'should return a non-nil, non-blank sourceUrl' do 
    @doc['sourceUrl'].class.to_s.should == 'String'
    @doc['sourceUrl'].length.should > 0
  end

  it 'should return a publishDate' do
    @doc['publishDate'].should match(/\d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ/)
  end

  it 'should return a non-nil, non-blank title' do
    @doc['title'].class.to_s.should == 'String'
    @doc['title'].length.should > 0
  end

  it 'should return at least one topic' do
    @doc['topics']['topics'].length.should > 0
    @doc['topics']['topics'][0]['key'].class.to_s.should == 'String'
    @doc['topics']['topics'][0]['key'].length.should > 0
    @doc['topics']['topics'][0]['value'].to_s.length.should > 0
  end

  it 'should return at least one concept' do
    @doc['topics']['concepts'].length.should > 0
    @doc['topics']['concepts'][0]['key'].class.to_s.should == 'String'
    @doc['topics']['concepts'][0]['key'].length.should > 0
    @doc['topics']['concepts'][0]['value'].to_s.length.should > 0
  end

  it 'should return a non-blank, non-nil value number for each topic' do
    @doc['topics']['topics'].each do |t|
      t['value'].class.to_s.should == 'Float'
    end 
  end

  it 'should return a non-blank, non-nil value number for each concept' do
    @doc['topics']['concepts'].each do |t|
      t['value'].class.to_s.should == 'Float'
    end 
  end

  it 'should return a cleanText string at least 50 chars long' do
    @doc['cleanText'].length.should >= 50
  end

  it 'should return an isClean value of true' do
    @doc['isClean'].to_s.should == 'true'
  end

  it 'should return an isLicensed value of true' do
    @doc['isLicensed'].to_s.should == 'true'
  end

  it 'should return a summary at least 100 chars' do 
    @doc['summary'].length.should >= 100
  end

  it 'should reutn a non-nil non-blank siteIcon value' do
    @doc['siteIcon'].class.to_s.should == 'String'
    @doc['siteIcon'].length.should > 0
  end

  it 'it should return a non-nil, non-blank siteId value' do
    @doc['siteId'].class.to_s.should == 'Fixnum'
    @doc['siteId'].should > 0
  end

end

