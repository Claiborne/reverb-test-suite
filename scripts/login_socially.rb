require 'rest-client'
require 'json'
require 'colorize'
require File.dirname(__FILE__)+'/../functional/lib/bifrost/token.rb'; include Token
require File.dirname(__FILE__)+'/../functional/lib/config_path.rb'

ENV['env'] = ARGV[0]
ConfigPath.config_path = File.dirname(__FILE__)+'/../functional/config/bifrost.yml'
env = "https://#{ConfigPath.new.options['baseurl']}"
puts get_social_token env