## Start Sidekiq
Codeburner uses <a href="http://sidekiq.org" target="_blank">Sidekiq</a> for asynchronous work (scanning code, sending notifications, etc.).  You'll need to explicitly start sidekiq as a separate process for Codeburner to actually "do" anything useful.  The default configuration options should work fine in most environments.

### Configuration
If you do need to customize sidekiq, it is configured in <a href="https://github.com/groupon/codeburner/blob/master/config/sidekiq.yml" target="blank">config/sidekiq.yml</a>.

### Startup
For local development/testing you can start sidekiq via:

```bash
bundle exec sidekiq
```

If you've deployed to a remote host (and configured Capistrano correctly) you should be able to start sidekiq with:

```bash
bundle exec cap <rails_env> sidekiq:start
```


## Start Codeburner!
Codeburner should work fine with most standard rack servers.  Internally it's been tested to work quite well with both <a href="https://unicorn.bogomips.org/" target="_blank">unicorn</a> and <a href="http://puma.io" target="_blank">puma.</a>

For local development, we recommend the standard WEBrick rails server and the spring gem for fast iteration.  You can start the main app server like so:

```bash
bundle exec rails s -p 8080
```

That will start Codeburner on port 8080, and at this point you should be able to open Codeburner by pointing a web browser at <a href="http://localhost:8080/" target="_blank">http://localhost:8080/</a>.

In a production environment, we recommend serving the root static content (<a href="https://github.com/groupon/codeburner/tree/master/public" target="_blank">public/</a>) with something like <a href="https://httpd.apache.org/" target="_blank">httpd</a> or <a href="http://www.nginx.com" target="_blank">nginx</a>.

!!! Developers
    If you change the port here, just note that you'll also need to change it in the client proxy config for the client development environment to pass API calls correctly.


***
