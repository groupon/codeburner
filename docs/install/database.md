### Installation
You'll need a copy of mysql server configured and running.  See instructions for your specific OS to accomplish this... the standard distro-provided mysql-server packages should work fine for Linux/BSD/etc., and the <a href="http://brew.sh/" target="_blank">Homebrew</a> version of MySQL works great for local development on OSX:

### Authentication
If you use a password for the 'root' user on MySQL locally, you'll need to add that password to the local block of <a href="https://github.com/groupon/codeburner/blob/master/config/database.yml" target="_blank">config/database.yml</a>

### Setup
Once the mysql service is running and you've configured the password, you can initialize the database like so:

```
bundle exec rake db:setup
```
