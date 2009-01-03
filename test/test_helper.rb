require "test/unit"

require File.dirname(__FILE__) + "/../lib/github_calendar"
require "sinatra/test"

require "rubygems"
require "context"
require "matchy"

module TestHelper
  def fixture(login)
    File.read(File.dirname(__FILE__) + "/fixtures/#{login}.atom")
  end
end

class Test::Unit::TestCase
  include TestHelper
  include Sinatra::Test
end
