# to run:
# ruby randomize_file.rb file_path new_file_path

require 'colorize'

raise ArgumentError, "To run this, you need two environment variables: (1) an existing file path and (2) a path to write the new file".red unless ARGV.length == 2

file_path = ARGV[0]
new_file_path = ARGV[1]
urls = []

File.open(file_path, "r").each_line do |line|
  urls << line
end

urls.shuffle!

File.open(new_file_path, 'w')  do |file|

  urls.each do |url|
    file.write url
  end
end