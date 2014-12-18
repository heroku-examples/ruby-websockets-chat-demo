require 'bundler'
Bundler.require

require './app'
require './middlewares/chat_backend'

use ChatDemo::ChatBackend

run ChatDemo::App
