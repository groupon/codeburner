![Codeburner](client/app/images/fire.png?raw=true "Codeburner") Codeburner
==========

One static analysis tool to rule them all.

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

## What is Codeburner?
Codeburner is a tool to help security (and dev!) teams manage the chaos of static code analysis.  Sure, you can fire off a bunch of scripts at the end of every CI build... but what do you actually DO with all those results?

Codeburner uses the OWASP pipeline project to run multiple open source and commercial static analysis tools against your code, and provides a unified (and we think rather attractive) interface to sort and act on the issues it finds.

Some key features:
* Fully asynchronous scanning that scales well
* Publish issues to JIRA or GitHub
* Advanced false positive filtering
* Statistics/charts show trends over time


## Local Development
You need, minimally, mysqld and redis-server installed and running.

### Environment
Clone the repository:

```
git clone https://github.com/groupon/codeburner
cd codeburner
gem install bundler
bundle install
```

Create the mysql database:

```
rake db:setup
```

### App Server
For development we recommend the standard WEBrick server with the spring gem for fast iteration:

```
bundle exec rails s -p 8080
```
Running in a production environment, codeburner has been tested and works well with both puma and unicorn.  While we haven't tested it with anything else, it should play nicely with most standard rack servers.

### Sidekiq
Codeburner uses sidekiq for asynchronous work.  To "do" anything useful (actually scan the code) you must first run:

```
bundle exec sidekiq ./config/sidekiq.yml
```

### Web Client
The code for the javascript client can be found in [./client](client).

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
The default deployment shouldn't start/restart sidekiq on the remote host.  You can start it the first time with:

```
cap <env> sidekiq:start
```

And if you've changed code that requires it (burn ignition, models, or notification pipeline) run:

```
cap <env> sidekiq:restart
```

## API
To trigger a code burn automatically, send it a payload containing a service name, code revision, and repository URL:

```
curl -H "Content-Type: application/json" -X POST -d '{"service_name":"my_cool_service", "revision":"abcdefg1234567890", "repo_url":"https://github.com/my/repo/url"}' http://localhost:8080/api/burn
```
