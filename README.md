# Ruby WebSockets Chat Demo

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

This is a simple application that serves tasty WebSockets to your users with [Plezi](https://github.com/boazsegev/plezi), [GRHttp](https://github.com/boazsegev/GRHttp), and [Sinatra](https://github.com/sinatra/sinatra).

Although Plezi could run the HTTP backend as well, we are using Sinatra to show how well everyone plays together and how to implement Websockets in your existing app.

Check out the [live demo](http://ruby-websockets-chat.herokuapp.com/) or [read the docs](https://devcenter.heroku.com/articles/ruby-websockets).

## Setup
To install all the dependencies, run:

```
bundle install
```

Next the app requires some env vars for configuration. A sample `.env.sample` is provided for running the app locally. You can copy `.env.sample` to `.env` which foreman will pick up.

Using foreman we can boot the application.

```
$ foreman start
```

You can now visit <http://localhost:5000> to see the application.
