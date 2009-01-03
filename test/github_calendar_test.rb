require File.dirname(__FILE__) + "/test_helper"

class GitHubCalendarTest < Test::Unit::TestCase
  describe "Feed" do
    before(:each) do
      @feed = GitHubCalendar::Feed.new
    end

    it "has an URI" do
      @feed.uri = "http://github.com/sr.atom"
      @feed.uri.should be_an(Addressable::URI)
      @feed.uri.to_s.should == "http://github.com/sr.atom"
    end

    it "has an etag" do
      @feed.etag = "01a747f19b4719dc1f6b1fa7be3b9529"
      @feed.etag.should == "01a747f19b4719dc1f6b1fa7be3b9529"
    end

    it "has a content" do
      @feed.content = "foo"
      @feed.content.should == "foo"
    end
  end

  it "finds 7 events" do
    feed = Atom::Feed.new(fixture(:sr))

    commits = GitHubCalendar.find_commits(feed)
    commits.length.should == 7
    commits.first.title.should == "sr committed to foca/integrity"
  end

  test "the web app" do
    GitHubCalendar::App.any_instance.expects(:open).
      with("http://github.com/sr.atom").returns(stub(:read => fixture(:sr)))

    @app = GitHubCalendar::App

    get "/~sr.ical"
    @response.status.should == 200
    @response["Content-Type"].should == "text/calendar"
    @response.body.should =~ /VCALENDAR/
  end
end
