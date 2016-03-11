This guide is intended to get you up and running with Codeburner as quickly as possible.  It assumes a basic level of experience working with <a href="https://www.docker.com/" target="_blank">Docker</a> containers.

The resulting image should be fully functional to test Codeburner in your environment.  However, it uses public docker images with known rails keys and has not been secured in any way or tuned for optimal performance (for example by having the static content served by something like nginx).  It **should not** be considered production ready in an enterprise environment.

That said if you'd like to make it ready yourself, the included <a href="https://github.com/groupon/codeburner/blob/master/Dockerfile" target="_blank">Dockerfile</a> and <a href="https://github.com/groupon/codeburner/blob/master/docker-compose.yml" target="_blank">docker-compose.yml</a> should get you most of the way there.

## Docker
You'll need <a href="https://www.docker.com/" target="_blank">Docker</a> installed with the **docker-compose** command available.

See instructions to accomplish this for your specific OS here: <a href="https://docs.docker.com/compose/install/" target="_blank">https://docs.docker.com/compose/install/</a>

!!! WARNING
    A bug in older docker versions (1.9.1) on OSX can cause the build to hang installing **ca-certificates-java**.  Upgrade to 1.10+ if you run into problems.

***

## Download
You can download the latest release of Codeburner here: <a href="https://github.com/groupon/codeburner/releases" target="_blank">https://github.com/groupon/codeburner/releases</a>

The rest of this guide assumes you're inside the directory created by unpacking a release tarball or cloning the repository:

<pre class="command-line"><code class="language-bash">git clone https://github.com/groupon/codeburner</code></pre>

***

## Configure
Minimally you'll want to configure GitHub access.  See the [Configuration Guide](/setup/configuration/) if you need to configure additional items (like JIRA access, etc).

### Generate a Token
To configure GitHub API access you'll need to generate a personal access token for Codeburner to use.  GitHub publishes a handy guide on creating tokens if you need help:

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

## Build
To build the container to run Codeburner and the scanning tools, you'll need to run the provided script:

<pre class="command-line language-bash"><code>sh ./docker-build.sh</code></pre>

!!! NOTE
    The Codeburner application and all the supported scanning tools have **many** dependencies.  This build process can take quite a while.

***

## Start Burning!
Once the container image is built, you can start the Codeburner application and all the dependent containers with docker-compose:

<pre class="command-line language-bash"><code>docker-compose up</code></pre>
