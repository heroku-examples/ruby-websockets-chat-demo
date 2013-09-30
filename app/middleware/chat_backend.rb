require 'faye/websocket'

class ChatBackend
  KEEPALIVE_TIME = 15 # in seconds

  def initialize(app)
    @app     = app
    @clients = {}
  end

  def call(env)
    if Faye::WebSocket.websocket?(env)
      ws = Faye::WebSocket.new(env)

      ws.on :open do |event|
        p [:open, ws.object_id]
        @clients[ws] = EM::PeriodicTimer.new(KEEPALIVE_TIME) do
          p [:ping, ws.object_id]
          ws.ping { p [:pong, ws.object_id] }
        end
      end

      ws.on :message do |event|
        p [:message, event.data]
        @clients.keys.each {|client| client.send(event.data) }
      end

      ws.on :close do |event|
        p [:close, ws.object_id, event.code, event.reason]
        @clients[ws].cancel
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
