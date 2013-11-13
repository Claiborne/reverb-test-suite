require '../functional/lib/config_path.rb'
require '../functional/lib/bifrost/token.rb'; include Token
ENV['env'] = ARGV[0]

ConfigPath.config_path = File.dirname(__FILE__) + "/../functional/config/bifrost.yml"
bifrost_env = "https://#{ConfigPath.new.options['baseurl']}"

puts get_anon_token bifrost_env