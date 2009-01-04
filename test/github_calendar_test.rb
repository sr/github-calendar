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
      @feed.uri.to_s.should == "http://0.0.0.0:3000/sr.atom"
    end

    it "has an etag" do
      @feed.etag.should == "01a747f19b4719dc1f6b1fa7be3b9529"
    end

    it "has a content" do
      @feed.content.should_not be_empty
    end

    it "requires an URI" do
      lambda do
        GitHubCalendar::Feed.gen(:sr, :uri => nil).should_not be_valid
      end.should_not change(GitHubCalendar::Feed, :count)
    end

    it "requires an ETag" do
      pending "FIXME: not sure about this... am I missusing dm hooks?" do
        lambda do
          GitHubCalendar::Feed.gen(:sr, :etag => nil).should_not be_valid
        end.should_not change(GitHubCalendar::Feed, :count)
      end
    end

    it "requires a content" do
      pending "FIXME: not sure about this... am I missusing dm hooks?" do
        lambda do
          GitHubCalendar::Feed.gen(:sr, :content => nil).should_not be_valid
        end.should_not change(GitHubCalendar::Feed, :count)
      end
    end

    it "requires URI to be a public feed from GitHub (for now)" do
      pending "FIXME" do
        lambda do
          GitHubCalendar::Feed.gen(:sr, :uri => "http://example.org").should_not be_valid
        end.should_not change(GitHubCalendar::Feed, :count)
      end
    end

    it "retrieve feed content and etag on create" do
      lambda do
        feed = GitHubCalendar::Feed.create(:uri => test_server_uri.join("sr.atom"))
        feed.uri.to_s.should == "http://0.0.0.0:3000/sr.atom"
        feed.etag.should     == %q{"bf1532b0add9f28c33e6651a9896691e"}
        feed.content.should  == feed_for(:sr)
      end.should change(GitHubCalendar::Feed, :count).by(1)
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

