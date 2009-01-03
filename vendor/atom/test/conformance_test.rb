begin
  require 'rubygems'
  require 'atom/test'
end unless defined?(Atom::Test)

require File.dirname(__FILE__) + '/test_helper'

Atom::Test.create_test_for! :all
