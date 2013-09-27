require 'sinatra/base'

class App < Sinatra::Base
  get "/" do
    File.read(File.join(File.dirname(__FILE__), "public/index.html"))
  end
end
