__DIR__ = File.dirname(__FILE__)
$:.unshift "#{__DIR__}/github_calendar", *Dir["#{__DIR__}/../vendor/**/lib"].to_a

require "icalendar"
require "ruby-debug"
require "em-http"
require "memcache"

require "digest/sha1"

require "atom" # vendored
require "core_ext"


module GitHubCalendar
  def self.cache
    @@cache ||= MemCache.new("0.0.0.0:11211")
  end

  class Feed
    attr_reader :uri, :expiry

    def initialize(uri, expiry=3600)
      @uri    = URI(uri)
      @expiry = expiry

      EM.defer(proc{fetch_and_cache}) unless cached?
    end

    def cached
      @cached ||= GitHubCalendar.cache.get(uri.to_s)
    end
    alias_method :cached?, :cached

    def to_etag
      @etag ||= Digest::SHA1.hexdigest(to_ical)
    end

    def to_ical
      @ical ||= begin
        calendar = Icalendar::Calendar.new

        feed.entries.each { |commit|
          calendar.event do
            dtstamp commit.published
            dtstart commit.published
            dtend   commit.published

            summary     commit.title.to_s
            description commit.content.value.to_s
            uid         commit.id
            klass       "PUBLIC"
          end
        }

        calendar.to_ical
      end
    end

    private
      def feed
        @feed ||= Atom::Feed.new(cached || "")
      end

      def fetch_and_cache
        http = EventMachine::HttpRequest.new(uri).get
        http.callback {
          GitHubCalendar.cache.set(uri.to_s, http.response, expiry)
        }
      end
  end

  class App < Sinatra::Base
    get "/~:user.ical" do
      halt(202) unless feed.cached?

      content_type "text/calendar"
      etag   feed.to_etag
      body   feed.to_ical
    end

    def feed
      @feed ||= Feed.new("http://github.com/sr.atom")
    end
  end
end
