require 'sinatra/base'

module ChatDemo
  class App < Sinatra::Base
    get "/" do
      slim :"index.html"
    end

    get "/main" do
      slim :"main.html"
    end

    get "/assets/js/application.js" do
      content_type :js
      @scheme = ENV['RACK_ENV'] == "production" ? "wss://" : "ws://"
      erb :"application.js"
    end

    get "/assets/js/button.js" do
      content_type :js
      @scheme = ENV['RACK_ENV'] == "production" ? "wss://" : "ws://"
      erb :"button.js"
    end
  end
end
