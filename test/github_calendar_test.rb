require "test/unit"

require "rubygems"
require "context"
require "matchy"

require File.dirname(__FILE__) + "/../lib/github_calendar"

class GitHubCalendarTest < Test::Unit::TestCase
  def fixture(login)
    File.read(File.dirname(__FILE__) + "/fixtures/#{login}.atom")
  end

  before(:each) do
    @feed = Atom::Feed.new(fixture(:sr))
  end

  it "finds 7 events" do
    GitHubCalendar.find_commits(@feed).length.should == 7
  end
end
