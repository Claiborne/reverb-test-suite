require 'rest-client'
require 'json'
require 'colorize'

social_wall_url = 'http://api.helloreverb.com/v2/trending/interests/social?limit=12&api_key=7d049c07a15408eea356dd6e88b744958ae2401d1d53729f'
global_wall_url = 'http://api.helloreverb.com/v2/trending/interests/global?limit=12&api_key=7d049c07a15408eea356dd6e88b744958ae2401d1d53729f'
headers = {:content_type => 'application/json', :accept => 'application/json'}

100.times do

    social_wall = JSON.parse (RestClient.get social_wall_url, headers)
    global_wall = JSON.parse (RestClient.get global_wall_url, headers)

    social_wall_words = []
    global_wall_words = []

    social_wall['interests'].each do |w|
      social_wall_words << w['value']
    end

    global_wall['interests'].each do |w|
      global_wall_words << w['value']
    end

    puts 'Social Words'.green
    (0..12).each do |n|
      puts "#{social_wall_words[n]}".yellow
    end

    puts 'News Words'.green
    (0..12).each do |n|
      puts "#{global_wall_words[n]}".yellow
    end

    sleep 60*30
end
