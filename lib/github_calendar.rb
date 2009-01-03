__DIR__ = File.dirname(__FILE__)
$:.unshift "#{__DIR__}/github_calendar", *Dir["#{__DIR__}/../vendor/**/lib"].to_a

require "rubygems"
require "icalendar"
require "dm-core"
require "dm-types"
require "dm-validations"
require "dm-timestamps"

require "open-uri"

# vendored
require "atom"
require "sinatra/base"

module GitHubCalendar
  CommitEvent = "tag:github.com,2008:CommitEvent".freeze

  def self.find_commits(feed)
    feed.entries.select { |entry| entry.id.start_with?(CommitEvent) }
  end

  class Feed
    include DataMapper::Resource

    property :id,       Serial
    property :uri,      URI
    property :etag,     Text
    property :content,  Text
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
      @feed ||= Atom::Feed.new(open("http://github.com/#{params[:user]}.atom").read)
    end
  end
end
