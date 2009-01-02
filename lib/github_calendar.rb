require "rubygems"
require "atom"

module GitHubCalendar
  CommitEvent = "tag:github.com,2008:CommitEvent"

  def self.find_commits(feed)
    feed.entries.select { |entry| entry.id.start_with?(CommitEvent) }
  end
end
