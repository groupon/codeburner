![Codeburner](client/app/images/fire.png?raw=true "Codeburner") Codeburner
==========

One static analysis tool to rule them all.

## What is Codeburner?
Codeburner is a tool to help security (and dev!) teams manage the chaos of static code analysis.  Sure, you can fire off a bunch of scripts at the end of every CI build... but what do you actually DO with all those results?

Codeburner uses the [OWASP pipeline](https://github.com/OWASP/pipeline) project to run multiple open source and commercial static analysis tools against your code, and provides a unified (and we think rather attractive) interface to sort and act on the issues it finds.

## Key Features
* Asynchronous scanning (via sidekiq) that scales
* Advanced false positive filtering
* Publish legit issues via GitHub or JIRA
* Tracks statistics and graphs security trends in your applications
* Integrates with a variety of open source and commercial scanning tools

## Supported Tools
* [Brakeman](http://brakemanscanner.org/)
* [Bundler-Audit](https://github.com/rubysec/bundler-audit)
* [Checkmarx](https://www.checkmarx.com/technology/static-code-analysis-sca/)
* [Dawnscanner](https://github.com/thesp0nge/dawnscanner)
* [FindSecurityBugs](https://find-sec-bugs.github.io/)
* [Node Security Project](https://nodesecurity.io/)
* [PMD](https://pmd.github.io/)
* [Retire.js](https://retirejs.github.io/retire.js/)

## Documentation
You can find full documentation for Codeburner at <a href="http://groupon.github.io/codeburner" target="_blank">http://groupon.github.io/codeburner</a>

## Installation
See our <a href="https://groupon.github.io/codeburner/install/" target="_blank">Installation Guide</a> for complete install instructions.

## API
To trigger a code burn automatically, send it a payload containing a service name, code revision, and repository URL:

```
curl -H "Content-Type: application/json" -X POST -d '{"service_name":"my_cool_service", "revision":"abcdefg1234567890", "repo_url":"https://github.com/my/repo/url"}' http://localhost:8080/api/burn
```
