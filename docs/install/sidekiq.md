Codeburner uses <a href="http://sidekiq.org" target="_blank">Sidekiq</a> for asynchronous work (scanning code, sending notifications, etc.).  You'll need to explicitly start sidekiq as a separate process for Codeburner to actually "do" anything useful.  The default configuration options should work fine in most environments.

### Configuration
If you do need to customize sidekiq, it is configured in <a href="https://github.com/groupon/codeburner/blob/master/config/sidekiq.yml" target="blank">config/sidekiq.yml</a>.

### Startup
For local development/testing you can start sidekiq via:

```
bundle exec sidekiq ./config/sidekiq.yml
```

If you've deployed to a remote host (and configured Capistrano correctly) you should be able to start sidekiq with:

```
bundle exec cap <rails_env> sidekiq:start
```
