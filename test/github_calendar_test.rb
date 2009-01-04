require File.dirname(__FILE__) + "/test_helper"

class GitHubCalendarTest < Test::Unit::TestCase
  before(:each) do
    setup_and_reset_database
  end

  describe "Feed" do
    before(:each) do
      @feed = GitHubCalendar::Feed.make(:sr)
    end

    test "fixture is valid and can be saved" do
      lambda do
        project = GitHubCalendar::Feed.generate(:sr)
        project.should be_valid
        project.save
      end.should change(GitHubCalendar::Feed, :count).by(1)
    end

    it "has an URI" do
      @feed.uri.should be_an(Addressable::URI)
      @feed.uri.to_s.should == "http://github.com/sr.atom"
    end

    it "has an etag" do
      @feed.etag.should == "01a747f19b4719dc1f6b1fa7be3b9529"
    end

    it "has a content" do
      @feed.content.should_not be_empty
    end

    it "requires an URI" do
      lambda do
        GitHubCalendar::Feed.gen(:uri => nil).should_not be_valid
      end.should_not change(GitHubCalendar::Feed, :count)
    end

    it "requires an ETag" do
      lambda do
        GitHubCalendar::Feed.gen(:etag => nil).should_not be_valid
      end.should_not change(GitHubCalendar::Feed, :count)
    end

    it "requires a content" do
      lambda do
        GitHubCalendar::Feed.gen(:content => nil).should_not be_valid
      end.should_not change(GitHubCalendar::Feed, :count)
    end

    it "requires URI to be a public feed from GitHub (for now)" do
      lambda do
        GitHubCalendar::Feed.gen(:uri => "http://example.org").should_not be_valid
      end.should_not change(GitHubCalendar::Feed, :count)
    end
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

