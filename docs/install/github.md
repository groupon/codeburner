### Generate a Token
Most of the functionality of Codeburner depends on GitHub access.  To configure GitHub API access you'll need to generate a personal access token for Codeburner to use.  GitHub publishes a handy guide on creating tokens if you need help:

<a href="https://help.github.com/articles/creating-an-access-token-for-command-line-use/" target="_blank">https://help.github.com/articles/creating-an-access-token-for-command-line-use/</a>


### Configuration
Once you have an access token, you can add it to <a href="https://github.com/groupon/codeburner/blob/master/config/app.yml" target="_blank">config/app.yml.</a>

If you're using GitHub Enterprise instead of public GitHub, you'll also want to change 'api_endpoint' here to the appropriate URL for API requests according to your GHE installation.
