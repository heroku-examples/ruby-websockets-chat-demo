require 'sinatra/base'

module ChatDemo
  class App < Sinatra::Base
    get "/" do
      erb :"index.html"
    end
  end
end
