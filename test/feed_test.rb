require File.dirname(__FILE__) + "/test_helper"

class FeedTest < Test::Unit::TestCase
  before(:each) do
    setup_and_reset_database
  end

  test "fixture is valid and can be saved" do
    lambda do
      project = GitHubCalendar::Feed.generate(:sr)
      project.should be_valid
      project.save
    end.should change(GitHubCalendar::Feed, :count).by(1)
  end

  describe "Properties and validations" do
    before(:each) do
      @feed = GitHubCalendar::Feed.make(:sr)
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
  end

  context "on create" do
    it "retrieve feed content and etag" do
      lambda do
        feed = GitHubCalendar::Feed.create(:uri => test_server_uri.join("sr.atom"))
        feed.uri.to_s.should == "http://0.0.0.0:3000/sr.atom"
        feed.etag.should     == %q{"bf1532b0add9f28c33e6651a9896691e"}
        feed.content.should  == feed_for(:sr)
        feed.should be_valid
      end.should change(GitHubCalendar::Feed, :count).by(1)
    end

    it "do not save if the feed can't be retrieved" do
      lambda do
        feed = GitHubCalendar::Feed.create(:uri => test_server_uri.join("not-found.atom"))
        feed.uri.to_s.should == "http://0.0.0.0:3000/not-found.atom"
        feed.etag.should be_nil
        feed.content.should be_nil
      end.should_not change(GitHubCalendar::Feed, :count)
    end
  end
end
