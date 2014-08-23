$LOAD_PATH << './../lib'
require 'aws-sdk' 
require 'pp'
require 'colorize'
require 'net/smtp'
require 'swf_helper'; include SWFHelper

set_up
closed_workflows = get_count_closed_workflows
contents = ''

# Header
contents << "The following data is from the past #@hours hour in #{ARGV[0]}\n\n"

# Percent failures
total = closed_workflows[0]['count'].to_f
failed = closed_workflows[2]['count'].to_f
percent_failed = (failed/total*100).to_s.match(/\A[0-9]{1,}/)
contents << "Percent Failures: #{percent_failed}%\n\n"

# Closed workflow breakdown
contents << "Closed Worflow Count\n"
closed_workflows.each do |i|
  contents << "\t#{i['status']}: #{i['count']}\n"
  contents << "\tWARNING: Turncated for the above is not false\n" unless !i[:turncated] 
end
contents << "\n"

# Open workflows
contents << "Current Open Worflow Count\n"
contents << "\tTotal: #{get_count_open_workflow_executions['count']}\n\n"

# Failure breakdown
contents << "Failure Breakdown\n"
contents << get_failure_breakdown


FROM_EMAIL = "reverbqualityassurance@gmail.com"
PASSWORD = "testpassword"
TO_EMAIL = ["wclaiborne@helloreverb.com", "odin@helloreverb.com"]

msgstr = <<END_OF_MESSAGE
From: Reverb QA (Do not reply) <#{FROM_EMAIL}>
To: QA <#{TO_EMAIL}>
Subject: Odin SWF Basic Monitoring
#{contents}
END_OF_MESSAGE

smtp = Net::SMTP.new 'smtp.gmail.com', 587
smtp.enable_starttls
smtp.start('gmail.com', 'reverbqualityassurance', PASSWORD, :login) do |smtp|
  smtp.send_message msgstr, FROM_EMAIL, TO_EMAIL
end