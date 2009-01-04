__DIR__ = File.dirname(__FILE__)
$:.unshift "#{__DIR__}/github_calendar", *Dir["#{__DIR__}/../vendor/**/lib"].to_a

require "rubygems"
require "icalendar"
require "dm-core"
require "dm-types"
require "dm-validations"
require "dm-aggregates"
require "dm-timestamps"

require "open-uri"
require "net/http"

# vendored
require "atom"
require "sinatra/base"

require "core_ext"

module GitHubCalendar
  CommitEvent = "tag:github.com,2008:CommitEvent".freeze

  def self.find_commits(feed)
    feed.entries.select { |entry| entry.id.start_with?(CommitEvent) }
  end

  class Feed
    include DataMapper::Resource

    property :id,       Serial
    property :uri,      URI,    :nullable => false
    property :etag,     String #:nullable => false
    property :content,  Text   #:nullable => false

    # FIXME: validates_with_method :uri, :method => :github_public_feed?

    before :create, :fetch_feed

    private
      def fetch_feed
        throw :halt unless new_record? && valid_uri?

        fetch_feed_first_time
      end

      def fetch_feed_first_time
        response = Net::HTTP.start(uri.host, uri.port || 80) { |http| http.get(uri.path) }

        throw :halt unless %w(200 304).include?(response.code)

        self.etag     = response["ETag"]
        self.content  = response.body
      end

      def valid_uri?
        uri && uri.host && uri.path
      end

      def github_public_feed?
        uri && uri.host == "github.com" && uri.path =~ /^\/\w+\.atom/
      end
  end

  class App < Sinatra::Base
    get "/~:user.ical" do
      calendar = Icalendar::Calendar.new
      GitHubCalendar.find_commits(fetch_feed).each do |commit|
        calendar.event do
          dtstamp commit.published
          dtstart commit.published
          dtend   commit.published

          summary     commit.title.to_s
          description commit.content.to_s
          uid         commit.id
          klass       "PUBLIC"
        end
      end

      content_type "text/calendar"
      body         calendar.to_ical
    end

    def fetch_feed
      unless feed = find_feed
        GitHubCalendar::Feed.create(:uri => "http://github.com/#{params[:user]}.atom")
      end
      @feed ||= Atom::Feed.new(open("http://github.com/#{params[:user]}.atom").read)
    end

    def find_feed
      GitHubCalendar::Feed.first(:uri => "http://github.com/#{params[:user]}.atom")
    end
  end
end
