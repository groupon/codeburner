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

### Configuration
You'll probably want to configure a few things before you start anything up.  Notably [config/database.yml](config/database.yml) and [config/app.yml](config/app.yml).

#### Database
Database configuration is in [config/database.yml](config/database.yml).  The defaults should be fine for development/test, you'll obviously want to configure staging and production as appropriate to your own environment.

#### Redis
Redis is configured in [config/application.rb](config/application.rb).  The defaults should be fine for local development, but you'll probably want to tweak them for a prod/HA deployment.

#### GitHub
Github is configured in [config/app.yml](config/app.yml).  For public github, you just need to set api_access_token to one that you generate from 'Account Settings/Personal access tokens' on GitHub.

#### JIRA
JIRA authentication is currently username/password, both of which can be configured in [config/app.yml](config/app.yml).  You'll also need to minimally set the host (for api connections) and link_host (a base url for generating clickable links) here.

#### Mail
Mail for burn notifications is configured in [config/app.yml](config/app.yml).  The 'link_host' variable is used when rendering notification e-mails as a base url for clickable links.


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

If you want to do development work on the frontend, please see the [README.md](client/README.md) file in the /client directory for more details.

### Scanning tools
While we're working on a more universal method of handling tools, support for individual scanning tools (that aren't included as ruby gems via pipeline:  bundler-audit, brakeman, dawnscanner) currently requires manual installation on your codeburner host.

#### RetireJS
Install RetireJS as a global node package:

```
npm install -g retire
```

#### NodeSecurityProject
NSP is also installed as a node package:

```
npm install -g nsp
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
