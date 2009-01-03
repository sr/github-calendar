require "test/unit"

require File.dirname(__FILE__) + "/../lib/github_calendar"
require "sinatra/test"

require "rubygems"
require "context"
require "matchy"
require "mocha"

require File.dirname(__FILE__) + "/helpers/expectations"
require File.dirname(__FILE__) + "/helpers/fixtures"

module TestHelper
  def setup_and_reset_database
    DataMapper.setup(:default, "sqlite3::memory:")
    DataMapper.auto_migrate!
  end

  def fixture(login)
    File.read(File.dirname(__FILE__) + "/helpers/fixtures/#{login}.atom")
  end
end

class Test::Unit::TestCase
  include TestHelper
  include Sinatra::Test
end
