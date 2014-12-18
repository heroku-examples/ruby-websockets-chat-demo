# -*- coding: utf-8 -*-
require 'faye/websocket'
require 'thread'
require 'redis'
require 'json'
require 'slim'

module ChatDemo
  class ChatBackend
    KEEPALIVE_TIME = 15 # in seconds
    CHANNEL = "rikimanai-demo"
    NAME = {
      "shuhei" => "しゅうへい",
      "kakizaki" => "柿崎",
      "abe" => "あべ",
      "koji" => "こうじ"
    }

    def initialize(app)
      @app     = app
      @clients = []
      uri = URI.parse(ENV["REDISCLOUD_URL"])
      @redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
      Thread.new do
        redis_sub = Redis.new(host: uri.host, port: uri.port, password: uri.password)
        redis_sub.subscribe(CHANNEL) do |on|
          on.message do |channel, msg|
            p "subscribe: count=#{@clients.count} : #{msg}"
            @clients.each {|ws|
              p "WebSocket:#{ws}"
              ws.send(msg)
            }
          end
        end
      end
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, ping: 15, retry: 10)
        ws.on :open do |event|
          p [:open, ws.object_id]
          @clients << ws
          @threshold = @redis.get "threshold"
          json = JSON.generate({
                                 command: "init",
                                 opt: {
                                   threshold: @threshold,
                                   counts: {
                                     shuhei: @redis.get("vote-shuhei"),
                                     kakizaki: @redis.get("vote-kakizaki"),
                                     abe: @redis.get("vote-abe"),
                                     koji: @redis.get("vote-koji")
                                   }
                                 }
                               })
          puts json
          @redis.publish CHANNEL, json
        end

        ws.on :message do |event|
          p [:message, event.data]
          data  = JSON.parse(event.data)
          case data["command"]
          when "rikinderu"
            count = @redis.incr("vote-#{data["target"]}")
            data["count"] = count
            @redis.publish(CHANNEL, sanitize(data))
            p "count=#{count}, threshold=#{@threshold}"
            if count >= @threshold
              target = data["target"]
              data["command"] = "out"
              data["name"] = NAME[target]
              @redis.publish(CHANNEL, sanitize(data))
              @redis.set data["vote-#{target}"], 0
            end
          when "threshold"
            @threshold = data["val"].to_i
            @redis.set "threshold", @threshold
          when "reset"
            reset
            @redis.publish(CHANNEL, sanitize(data))
          end
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

    private
    def sanitize(json)
      #json.each {|key, value| json[key] = ERB::Util.html_escape(value) }
      json = JSON.generate(json)
      p json
      json
    end

    def reset
      @redis.keys("vote-*").each do |key|
        @redis.set key, 0
      end
    end
  end
end
