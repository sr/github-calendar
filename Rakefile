require "rake/testtask"

desc "Default: run all tests"
task :default => :test

task :test => ["test:server:start", "test:run", "test:server:stop"]

namespace :test do
  desc "Run all test"
  Rake::TestTask.new(:run) do |t|
    t.test_files = FileList["test/*_test.rb"]
  end

  namespace :server do
    desc "Start the Thin server needed to run tests"
    task :start do
      sh "thin --daemonize --pid thin.pid --servers 1 --rackup test/helpers/github_faker.rb start"
      sleep 3
    end

    desc "Stop the Thin server needed to run tests"
    task :stop do
      sh "thin --pid thin.*.pid stop"
    end
  end
end
