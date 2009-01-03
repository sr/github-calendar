require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/clean'
require 'rake/gempackagetask'

Gem::manage_gems

task :default => ['test']

spec = Gem::Specification.new do |s|
  s.name = "atom"
  s.version = "0.3"
  s.author = "Martin Traverso"
  s.email = "mtraverso@acm.org"
  s.homepage = "http://http://rubyforge.org/projects/atom/"
  s.platform = Gem::Platform::RUBY
  s.summary = "Ruby library for working with the Atom syndication format"
  s.files =  FileList["lib/atom.rb", "lib/xmlmapping.rb"]
  s.require_path = "lib"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end 
