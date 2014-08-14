$LOAD_PATH << './../lib'
require 'aws-sdk' 
require 'pp'
require 'colorize'
require 'swf_helper'; include SWFHelper

TIME_FRAME = ARGV[0].to_i

TOTAL_CLOSED_COUNT_THRESHOLD = 10000*TIME_FRAME
COOMPLETED_CLOSED_COUNT_THRESHOLD = 40000*TIME_FRAME
FAILED_CLOSED_COUNT_THRESHOLD = 21000*TIME_FRAME
CANCELED_CLOSED_COUNT_THRESHOLD = 2*TIME_FRAME
TERMINATED_CLOSED_COUNT_THRESHOLD = 2*TIME_FRAME
CONT_AS_NEW_CLOSED_COUNT_THRESHOLD = 2*TIME_FRAME
TIMEOUT_CLOSED_COUNT_THRESHOLD = 2*TIME_FRAME

CURRENT_OPEN_WORKFLOWS_COUNT_THRESHOLD = 100*TIME_FRAME

TOTAL_PENDING_DECISION_TASKS_THRESHOLD = 10*TIME_FRAME
TOTAL_PENDING_ACTIVITY_TASKS_THRESHOLD = 0*TIME_FRAME

set_up

puts "\nThe following data is from the past #@hours hours in #{TIME_FRAME}".cyan

puts "\nClosed Worflows Count".green
get_count_closed_workflows.each do |i|
  puts "#{i['status']}: #{i['count']}"
  puts "WARNING: Turncated for the above is not false".red unless !i[:turncated] 
end

puts "\nCurrent Open Worflows Count".green
puts "Total: #{get_count_open_workflow_executions['count']}"

# Call the following method to see a breakdown of current open workflow counts
# The puts are in the methods; no need to puts here
debug_get_count_open_workflow_executions

puts "\nFailure Breakdown".green
get_failure_breakdown