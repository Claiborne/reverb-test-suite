require 'rest-client'
require 'json'
require 'colorize'

case ARGV[0]
when 'prd'
  url = "https://api.helloreverb.com/v2/clearMetrics"
when 'stg'
  url = "https://stage-api.helloreverb.com/v2/clearMetrics"
when 'dev'
  url = "https://dev-api.helloreverb.com/v2/clearMetrics"
else
  raise StandardError, "Need an ARGV[0] for which Bifrost env metrics to reset: prd, stg, or dev"
end

6.times do
  RestClient.delete url
  sleep 0.2
end