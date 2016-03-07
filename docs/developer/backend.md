## Application Server
The primary Codeburner application is a ruby 2/rails 4 service that provides the REST API and manages the asynchronous workers for scanning and notifications.

It uses <a href="http://sidekiq.org/" target="_blank">Sidekiq</a> with a redis queue for the asynchronous work.

***

## Ruby Environment
Codeburner was developed primarily on OSX with ruby 2.2 using the <a href="http://brew.sh" target="_blank">Homebrew</a> packages for MySQL and Redis.

***

## Database
<a href="http://www.mysql.com" target="_blank">MySQL</a> is the database of choice, and MySQL 5.6+ is recommended for use with <a href="https://github.com/airblade/paper_trail" target="_blank">paper_trail</a>, which is used to generate statistics.

***

## Caching
Caching is done via <a href="http://redis.io" target="_blank">Redis</a>.  In addition to being used for the standard rails transaction caching, Codeburner also pre-renders the results to the most common API queries ([GET /api/stats](/developer/api/#get-apistats) for example) and updates the cache whenever the models change.

***

## Sidekiq
Codeburner uses <a href="http://sidekiq.org/" target="_blank">Sidekiq</a> for asynchronous work.  It must be started as a separate process from the main application server as noted in the [Startup Guide](/setup/startup/#start-sidekiq).

You can pull up the GUI for sidekiq with the URL <a href="http://localhost:8080/sidekiq" target="_blank">http://localhost:8080/sidekiq</a>.  Here you can view the queue status and see what your workers are up to.  

If you've installed the <a href="https://github.com/mhfs/sidekiq-failures"  target="_blank">sidekiq-failures</a> gem, you can also get detailed information on failures complete with log snippets useful for debugging purposes.

***

## Unit Tests
Tests are in the <a href="https://github.com/groupon/codeburner/tree/master/test" target="_blank">/test</a> directory.  They're written in <a href="http://docs.seattlerb.org/minitest/" target="_blank">minitest/unit</a> using <a href="http://gofreerange.com/mocha/" target="_blank">Mocha</a> mocks.

If you submit patches to Codeburner, please ensure a '**rake test**' comes back clean:

<pre class="command-line language-bash" data-output="2-10"><code>bundle exec rake test
Running via Spring preloader in process 49701
Started with run options --seed 33780

  80/80: [================================================================] 100% Time: 00:00:01, Time: 00:00:01

Finished in 1.60502s
80 tests, 213 assertions, 0 failures, 0 errors, 0 skips
Coverage report generated for MiniTest to ~/codeburner/coverage. 574 / 574 LOC (100.0%) covered.</pre></code>

When adding new functionality, make sure to add tests for that functionality to the appropriate <a href="https://github.com/groupon/codeburner/tree/master/test" target="_blank">/test</a> directory.


***
