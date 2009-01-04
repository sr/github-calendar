require "dm-sweatshop"

include DataMapper::Sweatshop::Unique

GitHubCalendar::Feed.fixture(:sr) do
  { :uri      => "http://0.0.0.0:3000/sr.atom",
    :etag     => "01a747f19b4719dc1f6b1fa7be3b9529",
    :content  => feed_for(:sr) }
end
