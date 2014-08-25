$LOAD_PATH << './../lib'
require 'aws-sdk' 
require 'pp'
require 'colorize'
require 'swf_helper'; include SWFHelper

set_up

puts "\nThe following data is from the past #@hours hours in #{ARGV[0]}".cyan

puts "\nClosed Worflow Count".green
get_count_closed_workflows.each do |i|
  puts "#{i['status']}: #{i['count']}"
  puts "WARNING: Turncated for the above is not false".red unless !i[:turncated] 
end

puts "\nCurrent Open Worflow Count".green
puts "Total: #{get_count_open_workflow_executions['count']}"

# Call the following method to see a breakdown of current open workflow counts
# The puts are in the methods; no need to puts here
debug_get_count_open_workflow_executions

#puts "\nFailure Breakdown".green
#get_failure_breakdown
