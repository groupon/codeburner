## Download
You can download the latest release tarball of Codeburner here: <a href="https://github.com/groupon/codeburner/releases" target="_blank">https://github.com/groupon/codeburner/releases</a>

If you like to live dangerously (or want to try the latest features) you can also clone the latest master:

```
git clone https://github.com/groupon/codeburner
```

The rest of this guide assumes you're inside the directory unpacked by one of these methods when running commands.


## Ruby
Codeburner was developed on Ruby 2.2, and is tested with/works fine on 2.3.  If you're using [RVM](http://rvm.io) or [rbenv](http://rbenv.org) we've provided a .ruby-version so you should be all set.  If you aren't using one of those, just make sure your local ruby version is at least 2.2+ before proceeding.


## Bundler
First you'll need to install the bundler gem, if you don't already have it.

```
gem install bundler
```

Once you have bundler, you can use it to install the local gems for Codeburner:

```
bundle install
```

## Database
### Installation
You'll need a copy of mysql server configured and running.  See instructions for your specific OS to accomplish this... the standard distro-provided mysql-server packages should work fine for Linux/BSD/etc., and the <a href="http://brew.sh/" target="_blank">Homebrew</a> version of MySQL works great for local development on OSX:

### Authentication
If you use a password for the 'root' user on MySQL locally, you'll need to add that password to the local block of <a href="https://github.com/groupon/codeburner/blob/master/config/database.yml" target="_blank">config/database.yml</a>

### Setup
Once the mysql service is running and you've configured the password, you can initialize the database like so:

```
bundle exec rake db:setup
```

## Redis
### Installation
Codeburner uses redis both for rails caching and asynchronous queueing with sidekiq.  Again the standard os-provided redis packages should work fine on Linux/BSD/etc., and for OSX the homebrew redis package works great locally.


### Configuration
Using default configuration, you shouldn't need to change anything for local redis.  If you run redis on a host other than localhost or a port other than the default (6379), you can configure it by changing the relevant $redis_options line in <a href="https://github.com/groupon/codeburner/blob/master/config/application.rb" target="_blank">config/application.rb</a>


## GitHub
### Generate a Token
Most of the functionality of Codeburner depends on GitHub access.  To configure GitHub API access you'll need to generate a personal access token for Codeburner to use.  GitHub publishes a handy guide on creating tokens if you need help:

<a href="https://help.github.com/articles/creating-an-access-token-for-command-line-use/" target="_blank">https://help.github.com/articles/creating-an-access-token-for-command-line-use/</a>


### Configuration
Once you have an access token, you can add it to <a href="https://github.com/groupon/codeburner/blob/master/config/app.yml" target="_blank">config/app.yml.</a>

If you're using GitHub Enterprise instead of public GitHub, you'll also want to change 'api_endpoint' here to the appropriate URL for API requests according to your GHE installation.


## JIRA


## E-Mail

## Sidekiq

## Start Codeburner!
