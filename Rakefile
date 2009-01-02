require "rake/testtask"

desc "Default: run all tests"
task :default => :test

desc "Run all test"
Rake::TestTask.new(:test) do |t|
  t.test_files = FileList["test/*_test.rb"]
end
