require 'atom'
require 'net/http'
require 'uri'

class NingEntry < Atom::Entry
  namespace "http://www.ning.com/atom/1.0"
  has_one :is_private, :name => 'private', :transform => lambda { |v| v == 'true' }
  has_one :application
  has_one :content_type, :name => 'type'
end


class NingFeed < Atom::Feed
  has_many :entries, :name => 'entry', :type => NingEntry
end


class Restaurant < NingEntry
  namespace "http://restaurants.ning.com/xn/atom/1.0"

  has_one :cuisine
  has_one :rating, :name => 'avgRating', :transform => lambda { |v| v.to_f }

  has_one :latitude, :transform => lambda { |v| v.to_f }
  has_one :longitude, :transform => lambda { |v| v.to_f }
end

class RestaurantFeed < Atom::Feed
  has_many :entries, :name => 'entry', :type => Restaurant
end


s = Net::HTTP.get(URI.parse("http://restaurants.ning.com/xn/atom/1.0/content?to=10"))
feed = RestaurantFeed.new(s)

feed.entries.each { |restaurant| 
  puts "-----------------------------------------"
  puts restaurant.title
  puts restaurant.summary
  puts "Added on #{restaurant.published.strftime('%m/%d/%Y')} by #{restaurant.authors.first.name}"
  puts "Cuisine: #{restaurant.cuisine}"
  puts "Rating: #{restaurant.rating}"
}
