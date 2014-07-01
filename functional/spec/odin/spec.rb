require 'bunny'
require 'json'

conn = Bunny.new(:host => "localhost", :port => 5672)

begin
	conn.start
	ch = conn.create_channel

  message = {
	  "eventName" => "com.reverb.events.odin.package$Submission",
	  "requestId" => '350',
	  "url" => 'http://www.reuters.com/article/2014/06/30/us-usa-immigration-idUSKBN0F52GY20140630',
	  "source" => "ReverbTestSuite"
  }.to_json

	ch.direct('online-messaging', :durable => true).publish(message, :routing_key => 'global.urlSubmission')
rescue => e
	raise e
ensure
	conn.close
end

# Receiving IngestionNotification messages from Odin 
# create a queue with the name global.urlIngestionResult.itd-service
# create a binding from the exchange online-messaging and the routing key global.urlIngestionResult
# create a consumer for the queue

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