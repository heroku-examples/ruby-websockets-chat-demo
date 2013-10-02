require 'eventmachine'
require './app/app'
require './app/middleware/chat_backend'

EM.run {
  server = 'thin'
  host   = '0.0.0.0'
  port   = ENV['PORT']

  Faye::WebSocket.load_adapter('thin')

  app = Rack::Builder.new do
    use ChatBackend
    run App
  end

  Rack::Server.start({
    app:    app,
    server: server,
    Host:   host,
    Port:   port
  })
}
