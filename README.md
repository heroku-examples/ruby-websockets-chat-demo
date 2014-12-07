# Zero Downtime Deploy Demo

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

This is a simple application that serves tasty WebSockets to your users with [faye-websocket](https://github.com/faye/faye-websocket-ruby), [Puma](https://github.com/puma/puma), and [Sinatra](https://github.com/sinatra/sinatra).

The backend code has been modified from the original project to illustrate what happens during a Heroku deploy.

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
