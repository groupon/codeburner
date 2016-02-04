![Codeburner](client/app/images/fire.png?raw=true "Codeburner") Codeburner
==========

Static code analysis triggered by service portal deploy notifications

  * [Local Development](#local-development)
    * [Environment](#environment)
    * [Sidekiq](#sidekiq)
    * [Rack Server](#rack-server)
    * [Web Client](#web-client)
    * [Notifications](#notifications)
  * [Deployment](#deployment)
    * [Code Deploy](#code-deploy)
    * [Sidekiq Capistrano](#sidekiq-capistrano)
  * [API](#api)


## Local Development
You need, minimally, mysqld and redis-server installed and running.

### Environment
Clone the repo:

```
git clone https://github.com/groupon/codeburner
cd codeburner
gem install bundler
bundle install
```

Create the mysql database:

```
rake db:create
rake db:schema:load
```

### Sidekiq
Codeburner uses sidekiq for asynchronous work.  To "do" anything useful you must first run:

```
bundle exec sidekiq ./config/sidekiq.yml
```

If you have sidekiq pro (and modified the Gemfile accordingly), you can reach the sidekiq web interface at /sidekiq to check the status of queues, view failure exceptions, etc.

### Rack Server
Codeburner should work with any standard Rack server.  By default we're using Unicorn in production and the standard WEBrick rails server with the spring gem (on port 8080) for fast local iteration:

```
bundle exec rails s -p 8080
```

### Web Client
The code for the javascript client can be found in ./client:
[https://github.com/groupon/codeburner/client](https://github.com/groupon/codeburner/client)

The default cap deploy will build the client and pull the results into /public.  To do this manually, use the following cap task:

```
cap frontend:build
```

### Notifications
You must have a local MTA (sendmail/postfix/etc) capable of deliverying to external addresses if you want to test e-mail notifications

## Deployment
Codeburner is designed to use fairly standard capistrano based deployment.  However, the Capfile we've included is very basic and won't work out of the box.  Once you get that configured per your environment, you should be able to do something like...

### Code Deploy

```
cap <env> deploy
```

### Sidekiq Capistrano
The default deployment **_DOES NOT_** start/restart sidekiq on the remote host.  You can start it the first time with:

```
cap <env> sidekiq:start
```

And if you've changed code that requires it (burn ignition, models, or notification pipeline) run:

```
cap <env> sidekiq:restart
```

## API
To trigger a code burn, send it a payload containing a service name and code revision:

```
curl -H "Content-Type: application/json" -X POST -d '{"service_name":"my_cool_service", "revision":"abcdefg1234567890", "repo_url":"https://github.com/my/repo/url"}' http://localhost:8080/burn
```
