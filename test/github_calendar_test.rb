require "test/unit"

require "rubygems"
require "context"
require "matchy"

require File.dirname(__FILE__) + "/../lib/github_calendar"

class GitHubCalendarTest < Test::Unit::TestCase
  it "exists" do
    GitHubCalendar.class.should == Module
  end
end
