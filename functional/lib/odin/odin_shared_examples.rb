shared_examples 'Submit' do

  it 'should submit article to Odin' do
    @ch.direct('online-messaging', :durable => true).publish(@message, :routing_key => 'global.urlSubmission')
  end

end

shared_examples 'Shared correlated and parsed' do
  %w(correlated parsed).each do |notification_name|
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
    end # end it
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

shared_examples 'Shared filtered with docFilterOkay' do

  %w(filtered docFilterOkay).each do |notification_name|
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

  it 'should recieve these notifications in order: correlated parsed docFilterOkay filtered' do
    expected_notifications = %w(correlated parsed filtered)
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

  it 'should not recieve these notifications: correlated parsed filtered' do
    %w(correlated parsed filtered).each do |notification_name|
      notification = extractNotification @odin_notifications, notification_name
      notification.should be_nil
    end
  end
end

shared_examples 'Shared standard success' do

  %w(docFilterOkay docDedupOkay mediaExtractionOkay topicExtractionOkay conceptExtractionOkay).each do |notification_name|
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

  %w(docDedupOkay mediaExtractionOkay topicExtractionOkay conceptExtractionOkay).each do |notification_name|
    it "should return a #{notification_name}.value of true" do
      notification = extractNotification @odin_notifications, notification_name
      notification[notification_name]['value'].should == true
    end
  end
end

shared_examples 'Shared all' do

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

shared_examples 'Debug' do
  it 'should puts debug format above', :debug => true do
    puts @odin_notifications
  end
end

=begin

    # specific to submitting a 301
    it 'should return the apporpriate correlated.originalUri and correlated.expandedUri when originalUri 301s' do
      correlated = extractNotification @odin_notifications, 'correlated'
      correlated['correlated']['originalUri'].should == @url_submitted
      correlated['correlated']['expandedUri'].should == 'http://www.ign.com/articles/2014/07/07/googles-3d-mapping-phones-to-help-robots-on-the-international-space-station'
    end

=end