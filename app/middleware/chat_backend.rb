require 'faye/websocket'
require 'em-hiredis'
require 'thread'

Thread.abort_on_exception = true

class ChatBackend
  KEEPALIVE_TIME = 15 # in seconds
  CHANNEL        = "chat-demo"

  def initialize(app)
    @app     = app
    @clients = {}
    @redis   = EM::Hiredis.connect(ENV["REDISCLOUD_URL"])
    @redis.pubsub.subscribe(CHANNEL) do |msg|
      @clients.keys.each {|ws| ws.send(msg) }
    end
  end

  def call(env)
    if Faye::WebSocket.websocket?(env)
      ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })
      ws.on :open do |event|
        p [:open, ws.object_id]
        @clients[ws] = 1
      end

      ws.on :message do |event|
        p [:message, event.data]
        @redis.publish(CHANNEL, event.data)
      end

      ws.on :close do |event|
        p [:close, ws.object_id, event.code, event.reason]
        @clients.delete(ws)
        ws = nil
      end

      # Return async Rack response
      ws.rack_response

    else
      @app.call(env)
    end
  end
end
