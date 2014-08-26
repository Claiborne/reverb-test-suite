require 'rest-client'
require 'net/smtp'
require 'json'
require 'colorize'

case ARGV[0]
when 'prd'
  url = "https://api.helloreverb.com/v2/audit/metrics"
when 'stg'
  url = "https://stage-api.helloreverb.com/v2/audit/metrics"
when 'dev'
  url = "https://dev-api.helloreverb.com/v2/audit/metrics"
else
  raise StandardError, "Need an ARGV[0] for which Bifrost env to monitor: prd, stg, or dev"
end

p95_warning = 4000.0

content = ""
content << "The following Bifrost metrics had a p95 line over #{p95_warning.to_s.match(/\A[0-9]{1,}/)}ms"

bifrost_metrics = JSON.parse RestClient.get url, :content_type => 'application/json'

bifrost_components = []
bifrost_metrics.each do |k,v|
  bifrost_components << k
end
expected_number_of_keys = 20
content << "\nWARNING: expected at least #{expected_number_of_keys} keys returned by the audit metrics endpoint. Got #{bifrost_components.count}" unless bifrost_components.count >= expected_number_of_keys

metric_checked = 0

bifrost_components.each do |bifrost_component|
  bifrost_metrics[bifrost_component].each do |bifrost_metric|
    if bifrost_metric.to_s.match(/duration/)
      if bifrost_metric[1]['duration']['p95'] > p95_warning
        content << "\n\n#{bifrost_metric[0]}"
        content << "\n#{bifrost_metric[1]['duration']['p95']}"
      end
      metric_checked += 1
    end
  end
end

expected_number_of_metrics_checked = 45
content << "\nWARNING: only #{metric_checked} metrics were checked. Expected #{expected_number_of_metrics_checked}" unless metric_checked >= expected_number_of_metrics_checked

FROM_EMAIL = "reverbqualityassurance@gmail.com"
PASSWORD = "testpassword"
TO_EMAIL = "wclaiborne@helloreverb.com"

msgstr = <<END_OF_MESSAGE
From: Reverb QA (Do not reply) <#{FROM_EMAIL}>
To: QA <#{TO_EMAIL}>
Subject: Bifrost Audit Metrics Monitoring
#{content}
END_OF_MESSAGE

smtp = Net::SMTP.new 'smtp.gmail.com', 587
smtp.enable_starttls
smtp.start('gmail.com', 'reverbqualityassurance', PASSWORD, :login) do |smtp|
  smtp.send_message msgstr, FROM_EMAIL, TO_EMAIL
end
