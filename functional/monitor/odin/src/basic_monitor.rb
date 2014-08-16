$LOAD_PATH << './../lib'
require 'aws-sdk' 
require 'pp'
require 'colorize'
require 'net/smtp'
require 'swf_helper'; include SWFHelper

TIME_FRAME = ARGV[1].to_i
IGNORE = 1000000000

TOTAL_CLOSED_COUNT_THRESHOLD = 1*TIME_FRAME
COMPLETED_CLOSED_COUNT_THRESHOLD = IGNORE*TIME_FRAME
FAILED_CLOSED_COUNT_THRESHOLD = 1*TIME_FRAME
CANCELED_CLOSED_COUNT_THRESHOLD = IGNORE*TIME_FRAME
TERMINATED_CLOSED_COUNT_THRESHOLD = 1*TIME_FRAME
CONT_AS_NEW_CLOSED_COUNT_THRESHOLD = IGNORE*TIME_FRAME
TIMEOUT_CLOSED_COUNT_THRESHOLD = 1*TIME_FRAME

CURRENT_OPEN_WORKFLOWS_COUNT_THRESHOLD = 1

TOTAL_PENDING_DECISION_TASKS_THRESHOLD = 1
TOTAL_PENDING_ACTIVITY_TASKS_THRESHOLD = 1

warning_contents = ''

set_up

get_count_closed_workflows.each do |count|
  case count['status']

  when 'Total'
    c = count['count']
    msg = "There were #{c} total closed workflows in the past #{TIME_FRAME} hours.\n"
     warning_contents << msg if c > TOTAL_CLOSED_COUNT_THRESHOLD
  when 'Completed'
    c = count['count']
    msg = "There were #{c} workflows closed as 'Completed' in the past #{TIME_FRAME} hours.\n"
    warning_contents << msg if c > COMPLETED_CLOSED_COUNT_THRESHOLD
  when 'Failed'
    c = count['count']
    msg = "There were #{c} workflows closed as 'Failed' in the past #{TIME_FRAME} hours.\n"
    warning_contents << msg if c > FAILED_CLOSED_COUNT_THRESHOLD
  when 'Canceled'
    c = count['count']
    msg = "There were #{c} workflows closed as 'Canceled' in the past #{TIME_FRAME} hours.\n"
    warning_contents << msg if c > CANCELED_CLOSED_COUNT_THRESHOLD
  when 'Terminated'
    c = count['count']
    msg = "There were #{c} workflows closed as 'Terminated' in the past #{TIME_FRAME} hours.\n"
    warning_contents << msg if c > TERMINATED_CLOSED_COUNT_THRESHOLD
  when 'Continued_as_new'
    c = count['count']
    msg = "There were #{c} workflows closed as 'Continued_as_new' in the past #{TIME_FRAME} hours.\n"
    warning_contents << msg if c > CONT_AS_NEW_CLOSED_COUNT_THRESHOLD
  when 'Timed_out'
    c = count['count']
    msg = "There were #{c} workflows closed as 'Timed_out' in the past #{TIME_FRAME} hours.\n"
    warning_contents << msg if c > TIMEOUT_CLOSED_COUNT_THRESHOLD
  else
    raise "#{count['status']} is not an expected closed status"
  end
end

current_open_workflows = get_count_open_workflow_executions['count']
msg = "There were #{current_open_workflows} open workflows\n"
warning_contents << msg if current_open_workflows > CURRENT_OPEN_WORKFLOWS_COUNT_THRESHOLD

pending_workflows = get_pending_workflow_executions
pending_decisions = pending_workflows[:decisions]+2
pending_activities = pending_workflows[:activities]+2
msg = "There were #{pending_decisions} total pending decisions\n"
warning_contents << msg if pending_decisions > TOTAL_PENDING_DECISION_TASKS_THRESHOLD
msg = "There were #{pending_activities} total pending activities\n"
warning_contents << msg if pending_activities > TOTAL_PENDING_ACTIVITY_TASKS_THRESHOLD

if warning_contents.length > 0

  FROM_EMAIL = "reverbqualityassurance@gmail.com"
  PASSWORD = "testpassword"
  TO_EMAIL = ["wclaiborne@helloreverb.com"]

  msgstr = <<END_OF_MESSAGE
From: Reverb QA (Do not reply) <#{FROM_EMAIL}>
To: QA <#{TO_EMAIL}>
Subject: Odin Warnings
#{warning_contents}
END_OF_MESSAGE

  smtp = Net::SMTP.new 'smtp.gmail.com', 587
  smtp.enable_starttls
  smtp.start('gmail.com', 'reverbqualityassurance', PASSWORD, :login) do |smtp|
    smtp.send_message msgstr, FROM_EMAIL, TO_EMAIL
  end
end
