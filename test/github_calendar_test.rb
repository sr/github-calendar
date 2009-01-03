require File.dirname(__FILE__) + "/test_helper"

class GitHubCalendarTest < Test::Unit::TestCase
  before(:each) do
    @feed = Atom::Feed.new(fixture(:sr))
  end

  it "finds 7 events" do
    commits = GitHubCalendar.find_commits(@feed)
    commits.length.should == 7
    commits.first.title.should == "sr committed to foca/integrity"
  end

  test "the web app" do
    @app = GitHubCalendar::App

    get "/~sr.ical"
    @response.status.should == 200
    @response["Content-Type"].should == "text/calendar"
    @response.body.should =~ /VCALENDAR/
  end
end
