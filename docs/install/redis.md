### Installation
Codeburner uses redis both for rails caching and asynchronous queueing with sidekiq.  Again the standard os-provided redis packages should work fine on Linux/BSD/etc., and for OSX the homebrew redis package works great locally.


### Configuration
Using default configuration, you shouldn't need to change anything for local redis.  If you run redis on a host other than localhost or a port other than the default (6379), you can configure it by changing the relevant $redis_options line in <a href="https://github.com/groupon/codeburner/blob/master/config/application.rb" target="_blank">config/application.rb</a>
