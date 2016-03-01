### Configuration
If you plan to publish issues to JIRA instead of (or in addition to) GitHub, you'll also need to configure some JIRA options in <a href="https://github.com/groupon/codeburner/blob/master/config/app.yml" target="_blank">config/app.yml.</a>

Minimally you need to set username/password, host (which is the FQDN of the root JIRA API endpoint), and link_host (used to generate clickable links).  You'll also probably want to set use_ssl to 'true' if possible so you aren't sending credentials in clear text.
