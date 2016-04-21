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

## Build
To build the container to run Codeburner and the scanning tools, you'll need to run the provided script:

<pre class="command-line language-bash"><code>sh ./docker-build.sh</code></pre>

!!! NOTE
    The Codeburner application and all the supported scanning tools have **many** dependencies.  This build process can take quite a while.

***

## Start Burning!
Once the container image is built, you can start the Codeburner application and all the dependent containers with docker-compose:

<pre class="command-line language-bash"><code>docker-compose up</code></pre>

You can then bring up Codeburner in a web browser by pointing it at your docker IP on port 3000.

!!! NOTE
    If you're running docker under docker-machine, you can get the docker IP with the command <strong>docker-machine ip</strong>

## Configure

### Generate Tokens
To configure GitHub API access you'll need to generate both a personal access token for Codeburner to use for scanning and an OAuth key pair for authentication/authorization use.  GitHub publishes a handy guide on creating tokens if you need help:

<a href="https://help.github.com/articles/creating-an-access-token-for-command-line-use/" target="_blank">https://help.github.com/articles/creating-an-access-token-for-command-line-use/</a>

You'll also need to register Codeburner as an OAuth Application here:

<a href="https://github.com/settings/applications/new" target="_blank">https://github.com/settings/applications/new</a>

Make sure to copy both your personal access token and Client ID/Client Secret from the above steps to a secure location for entering in the Codeburner interface later.

### Required Configuration
Once you have an access token and client id/secret, you can configure Codeburner by clicking the "System Settings" link in the top menu bar.

First you'll want to configure GitHub access using the tokens generated above.  After you do that, you should sign-in to GitHub using the link on the far right of the top menu.  

When you return to the system settings interface, you can visit "Administrator Access" to configure Codeburner administrators.

!!! NOTE
    Settings are initially visible to any user.  Once you've specified administrator users however, only those users can view the settings page going forward.

### Optional Configuration

After configuring authentication and admin access, you can proceed to make any other config changes you need to.  We just switched over to the GUI-based configuration, but you can roughly follow the existing <a href="/setup/configuration/" target="_blank">Configuration Guide</a> if you need pointers... just put the appropriate values in to the UI instead of app.yml.

***
