require "test/unit"

require "rubygems"
require "context"
require "matchy"

require File.dirname(__FILE__) + "/../lib/github_calendar"

module TestHelper
  def fixture(login)
    File.read(File.dirname(__FILE__) + "/fixtures/#{login}.atom")
  end
end

class Test::Unit::TestCase
  include TestHelper
end
