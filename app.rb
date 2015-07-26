require 'sinatra/base'
require 'plezi'

module ChatDemo
  class App < Sinatra::Base
    get "/" do
      erb :"index.html"
    end

    get "/assets/js/application.js" do
      content_type :js
      @scheme = ENV['RACK_ENV'] == "production" ? "wss://" : "ws://"
      erb :"application.js"
    end
  end
end


# Plezi Websocket Backend
class WSBroadcaster
  def on_message data
    # send the sanitized data to all of the
    # websocket WSBroadcaster instance's :write method
    broadcast :write, sanitize(data)
    write data
  end

  protected

  # sends data to the websocket - must be protected using the _ prefix,
  # or it will be considered an available HTTP route.
  def write data
    response << data
  end

  private
  def sanitize(message)
    json = JSON.parse(message)
    json.each {|key, value| json[key] = ERB::Util.html_escape(value) }
    JSON.generate(json)
  end
end
# set up Plezi's Redis support
ENV['PL_REDIS_URL'] ||= ENV['REDIS_URL'] || ENV['REDISCLOUD_URL'] || ENV['REDISTOGO_URL']
# tell Plezi to listen for connections...
Plezi.listen
# set up the route to the websocket:
Plezi.route '/', WSBroadcaster
# tell plezi to run in Rack (Hybrid mode).
Plezi.start_rack
