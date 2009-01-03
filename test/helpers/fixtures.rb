require "dm-sweatshop"

include DataMapper::Sweatshop::Unique

def feed_for(login)
  File.read(File.dirname(__FILE__) + "/fixtures/#{login}.atom")
end

GitHubCalendar::Feed.fixture do
  { :uri      => "http://github.com/sr.atom",
    :etag     => "01a747f19b4719dc1f6b1fa7be3b9529",
    :content  => feed_for(:sr) }
end

GitHubCalendar::Feed.fixture(:sr) do
  { :uri      => "http://github.com/sr.atom",
    :etag     => "01a747f19b4719dc1f6b1fa7be3b9529",
    :content  => feed_for(:sr) }
end
