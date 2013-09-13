require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

ENV["env"] ||= 'stg'

desc "Run Bifrost tests"
RSpec::Core::RakeTask.new('bifrost') do |t|
  t.rspec_opts = ["-Ilib","--format documentation","--color"]
  t.pattern = 'spec/bifrost/**/*.rb'
end