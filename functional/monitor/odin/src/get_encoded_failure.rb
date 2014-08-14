$LOAD_PATH << './../lib'
require 'aws-sdk' 
require 'pp'
require 'colorize'
require 'json'
require 'swf_helper'; include SWFHelper

set_up

raise "\n\nNeed an ARGV[2] for which failure message to look for.\nFor example, URI didn't expand to a 2xx statuscode\n\n".red unless ARGV[2]

get_encoded_stack_trace ARGV[2]
