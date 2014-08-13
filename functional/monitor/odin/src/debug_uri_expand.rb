$LOAD_PATH << './../lib'
require 'aws-sdk' 
require 'pp'
require 'colorize'
require 'json'
require 'swf_helper'; include SWFHelper

set_up

get_uri_expand_failure_details
