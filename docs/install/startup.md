Codeburner should work fine with most standard rack servers.  Internally it's been tested to work quite well with both <a href="https://unicorn.bogomips.org/" target="_blank">unicorn</a> and <a href="http://puma.io" target="_blank">puma.</a>

For local development, we recommend the standard WEBrick rails server and the spring gem for fast iteration.  You can start the main app server like so:

```
bundle exec rails s -p 8080 -b 0.0.0.0
```

In a production environment, we also recommend serving the javascript/client interface as static content via something like apache or nginx.  The current client build is served out of the <a href="https://github.com/groupon/codeburner/tree/master/public" target="_blank">public/</a> directory and will also be served as '/' from the development rails server above.
