require './app/app'
require './app/middleware/chat_backend'

Faye::WebSocket.load_adapter('thin')
use ChatBackend

run App
