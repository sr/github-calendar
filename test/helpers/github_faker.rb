require "md5"

require File.dirname(__FILE__) + "/../test_helper"

class Github_faker < Sinatra::Application
  get "/:user.atom" do
    feed = feed_for(params[:user])
    etag MD5.new(feed).hexdigest
    body feed
  end
end
