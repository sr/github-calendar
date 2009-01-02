require File.dirname(__FILE__) + "/test_helper"

class GitHubCalendarTest < Test::Unit::TestCase
  before(:each) do
    @feed = Atom::Feed.new(fixture(:sr))
  end

  it "finds 7 events" do
    GitHubCalendar.find_commits(@feed).length.should == 7
  end
end
