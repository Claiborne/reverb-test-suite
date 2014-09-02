require 'rest_client'
require 'json'
require 'time'
require 'net/smtp'

cookie = "pikachusession=token%3Dde4aae9e68244e9b79ade359416e6f29%3Busername%3Dwclaiborne%40helloreverb.com%3Btime%3D1402943367703"

contents = ""
contents << Time.now.to_s+"\n"
contents << "\n"
contents << "The last day 'avg daily time spent in app/user' was updated:\n"

url = "https://editorial.helloreverb.com/proxy/jigglypuff/api/metrics/weeklyDailyTimeInAppAveragesIpad"
begin
  r = RestClient.get url, :content_type => 'application/json', :accept => 'application/json', :cookie => cookie
rescue => e
  raise StandardError.new(e.message+":\n"+url)
end
data = JSON.parse r
contents << data['weekLabels'].last+"\n"
contents << "see: https://editorial.helloreverb.com/proxy/jigglypuff/api/metrics/weeklyDailyTimeInAppAveragesIpad\n"
contents << "\n\n"

contents << "The last day 'total installs to date' was updated:\n"

url = "https://editorial.helloreverb.com/proxy/jigglypuff/api/metrics/apple_downloads"
begin
  r = RestClient.get url, :content_type => 'application/json', :accept => 'application/json', :cookie => cookie
rescue => e
  raise StandardError.new(e.message+":\n"+url)
end
data = JSON.parse r
contents << data.last['date']+"\n"
contents << "see: https://editorial.helloreverb.com/proxy/jigglypuff/api/metrics/apple_downloads\n"
contents << "\n\n"

FROM_EMAIL = "reverbqualityassurance@gmail.com"
PASSWORD = "testpassword"
TO_EMAIL = ["wclaiborne@helloreverb.com"]

msgstr = <<END_OF_MESSAGE
From: Reverb QA (Do not reply) <#{FROM_EMAIL}>
To: QA <#{TO_EMAIL}>
Subject: Sexy Stats Smoke Test
#{contents}
END_OF_MESSAGE

smtp = Net::SMTP.new 'smtp.gmail.com', 587
smtp.enable_starttls
smtp.start('gmail.com', 'reverbqualityassurance', PASSWORD, :login) do |smtp|
  smtp.send_message msgstr, FROM_EMAIL, TO_EMAIL
end
