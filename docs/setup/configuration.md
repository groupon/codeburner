## Database
### Installation
You'll need a copy of mysql server configured and running.  See the <a href="dev.mysql.com/doc/en/installing.html" target="_blank">instructions</a> for your specific OS to accomplish this.  For local development on OSX the <a href="http://brew.sh" target="_blank">Homebrew</a> package works fine.

### Authentication
If you're using the 'root' user without a password for local development, you shouldn't need to configure anything here and can proceed to the Setup step below.

If you're using a secure mysql install and want to use a user other than 'root' (highly recommended), you'll need to create a database named 'codeburner_$RAILSENV' and grant access to it:

<pre class="command-line" data-output="2-7"><code class="language-bash">mysql -u root -p</code>
<code class="language-sql">
mysql> create database codeburner_development;
Query OK, 1 row affected (0.00 sec)

mysql> grant all privileges on codeburner_development.* to 'my_new_user'@'localhost' identified by 'some_secure_password';
Query OK, 0 rows affected (0.01 sec)
</code></pre>

Once that's done you'll want to make sure the new username/password are in <a href="https://github.com/groupon/codeburner/blob/master/config/database.yml" target="_blank">config/database.yml</a>:

```yaml
local: &local
  <<: *common
  host: 127.0.0.1
  password:
  username: root
  wait_timeout: 10000
```

### Setup
Once the mysql repo is running and you've configured the password, you can initialize the database:

<pre class="command-line"><code class="language-bash">bundle exec rake db:setup</code></pre>

***

## Redis
### Installation
Codeburner uses redis both for rails caching and asynchronous queueing with sidekiq.  Again the standard OS-provided redis packages should work fine on Linux/BSD/etc., the <a href="http://brew.sh" target="_blank">Homebrew</a> package works great on OSX.


### Configuration
Using the default configuration, you shouldn't need to change anything for local redis.  If you run redis on a host other than localhost, a port other than the default (6379), or you want to use a sentinel config for HA you can configure that by changing the relevant $redis_options line in <a href="https://github.com/groupon/codeburner/blob/master/config/application.rb" target="_blank">config/application.rb</a>:

```ruby
case ENV['RAILS_ENV']
when 'production'
  $redis_options = {
    :host => 'localhost',
    :port => 6379
  }
when 'staging'
  $redis_options = {
    :host => 'localhost',
    :port => 6379
  }
else
  $redis_options = {
    :host => 'localhost',
    :port => 6379
  }
end
```

***

## GitHub
### Generate a Token
Most of the functionality of Codeburner depends on GitHub access.  To configure GitHub API access you'll need to generate a personal access token for Codeburner to use.  GitHub publishes a handy guide on creating tokens if you need help:

<a href="https://help.github.com/articles/creating-an-access-token-for-command-line-use/" target="_blank">https://help.github.com/articles/creating-an-access-token-for-command-line-use/</a>

### Configuration
Once you have an access token, you can add it to <a href="https://github.com/groupon/codeburner/blob/master/config/app.yml" target="_blank">config/app.yml</a>:

```yaml
github:
  api_endpoint: https://api.github.com/
  api_access_token: my_github_api_token
  link_host: https://www.github.com
```

If you're using GitHub Enterprise instead of public GitHub, you'll also want to change 'api_endpoint' here to the appropriate URL for API requests and 'link_host' to the base URL for generating clickable links, both according to your local GHE installation.

***

## JIRA
### Configuration
If you plan to publish issues to JIRA instead of (or in addition to) GitHub, you'll also need to configure some JIRA options in <a href="https://github.com/groupon/codeburner/blob/master/config/app.yml" target="_blank">config/app.yml</a>:

```yaml
jira:
  username: my_jira_user
  password: my_jira_password
  host: https://my_jira_host
  context_path: ''
  use_ssl: true
  link_host: https://my_jira_host
```

Minimally you need to set username/password, host (which is the URL of the your JIRA install), and link_host (used to generate clickable links, if it's different from your API host).  You'll also probably want to set use_ssl to 'true' if possible so you aren't sending credentials in clear text.

***

## E-mail
### Configuration
Mail notifications assume you have a local MTA running that will accept and deliver mail properly.  You can configure some options for e-mail in <a href="https://github.com/groupon/codeburner/blob/master/config/app.yml" target="_blank">config/app.yml</a>:

```yaml
mail:
  from: '"Codeburner" <codeburner@myserver.com>'
  link_host:
    development: localhost:9000
    staging: localhost:9000
    production: localhost:9000
    test: localhost:9000
```

The 'link_host' variable is used when rendering notification e-mails as a base url for clickable links.


***
