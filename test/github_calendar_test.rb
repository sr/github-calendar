require File.dirname(__FILE__) + "/test_helper"

class GitHubCalendarTest < Test::Unit::TestCase
  before(:each) do
    setup_and_reset_database
  end

  it "finds 7 events" do
    feed = Atom::Feed.new(feed_for(:sr))

    commits = GitHubCalendar.find_commits(feed)
    commits.length.should == 7
    commits.first.title.should == "sr committed to foca/integrity"
  end

=begin
  test "the web app" do
    GitHubCalendar::App.any_instance.expects(:open).
      with("http://github.com/sr.atom").returns(stub(:read => fixture(:sr)))

    @app = GitHubCalendar::App

    get "/~sr.ical"
    @response.status.should == 200
    @response["Content-Type"].should == "text/calendar"
    @response.body.should =~ /VCALENDAR/
  end
=end
end

