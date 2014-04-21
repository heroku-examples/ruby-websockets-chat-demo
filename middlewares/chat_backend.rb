require 'faye/websocket'
require 'thread'
require 'redis'
require 'json'
require 'erb'

module ChatDemo
  class ChatBackend
    KEEPALIVE_TIME = 15 # in seconds
    CHANNEL        = "chat-demo"

    def initialize(app)
      @app     = app
      @clients = []
      if ENV["REDISCLOUD_URL"]
        uri = URI.parse(ENV["REDISCLOUD_URL"])
        @redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
        Thread.new do
          redis_sub = Redis.new(host: uri.host, port: uri.port, password: uri.password)
          redis_sub.subscribe(CHANNEL) do |on|
            on.message do |channel, msg|
              @clients.each {|ws| ws.send(msg) }
            end
          end
        end
      else
        @redis = Class.new do # dummy redis for local
          attr_accessor :clients
          def publish(channel, msg)
            if channel == CHANNEL
              @clients.each {|ws| ws.send(msg) }
            end
          end
        end.new
        @redis.clients = @clients
      end
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })
        ws.on :open do |event|
          p [:open, ws.object_id]
          @clients << ws
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
end
