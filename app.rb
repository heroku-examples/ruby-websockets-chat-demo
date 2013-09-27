require 'sinatra/base'

class App < Sinatra::Base
  get "/" do
    redirect "/index.html"
  end
end
