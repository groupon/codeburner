## Ruby Gems
A few of the scanning tools used by Codeburner are installed automatically as gem dependencies of <a href="https://github.com/OWASP/pipeline" target="_blank">pipeline</a>.  Those tools are:

* <a href="http://brakemanscanner.org/" target="_blank">Brakeman</a>
* <a href="https://github.com/rubysec/bundler-audit" target="_blank">Bundler-Audit</a>
* <a href="http://dawnscanner.org/" target="_blank">Dawnscanner</a>

The rest of the tools need to be installed manually...

***

## <a href="https://nodesecurity.io/" target="_blank">NodeSecurityProject</a>
NodeSecurityProject is distrubted as a node package.  You'll need <a href="https://www.npmjs.com/" target="_blank">npm</a> available to install it.  Once you have npm, you can install NodeSecurityProject with:

<pre class="command-line"><code class="language-bash">npm install -g nsp</code></pre>

Make sure that the installed 'nsp' command is in the $PATH for Codeburner.

***

## <a href="https://retirejs.github.io/retire.js/" target="_blank">Retire.js</a>
Retire.js is another node package.  It can be installed just like nsp:

<pre class="command-line"><code class="language-bash">npm install -g retire</code></pre>

Make sure that the installed 'retire' command is in the $PATH for Codeburner.

***

## <a href="https://find-sec-bugs.github.io/" target="_blank">FindSecurityBugs</a>
### Java
The find-sec-bugs CLI requires a working installation of <a href="https://www.java.com/en/download/help/download_options.xml" target="_blank">Java</a>, and the compilation step from <a href="https://github.com/OWASP/pipeline" target="_blank">pipeline</a> to generate bytecode requires <a href="https://maven.apache.org/" target="_blank">maven</a>.  Please make sure that both the 'mvn' and 'java' commands are available in the $PATH for Codeburner.

### Install
You can download the latest release of findsecbugs-cli here: <a href="https://github.com/find-sec-bugs/find-sec-bugs/releases/latest" target="_blank">https://github.com/find-sec-bugs/find-sec-bugs/releases/latest</a>

Once you've unpacked the release tarball, set the variable 'findsecbugs_path' to the location you unpacked it in <a href="https://github.com/groupon/codeburner/blob/master/config/app.yml" target="_blank">config/app.yml</a>:

```yaml
findsecbugs_path: /path/to/findsecbugs/install
```

!!! Note
    Due to the requirement of having compiled bytecode available, pipeline currently supports scanning via find-sec-bugs only on maven projects with a valid pom.xml.

***

## <a href="http://pmd.github.io" target="_blank">PMD</a>
### Java
As with FindSecurityBugs, PMD requires a working installation of <a href="https://www.java.com/en/download/help/download_options.xml" target="_blank">java</a> and the 'java' command available in the Codeburner $PATH.  Unlike FindSecurityBugs, PMD doesn't require compiled bytecode so it should work on most any java project.

### Install
PMD can be downloaded here: <a href="https://github.com/pmd/pmd/releases/latest" target="_blank">https://github.com/pmd/pmd/releases/latest</a>

Once you've unpacked the release tarball, set the variable 'pmd_path' to the location you unpacked it in <a href="https://github.com/groupon/codeburner/blob/master/config/app.yml" target="_blank">config/app.yml</a>:

```yaml
pmd_path: /path/to/pmd/install
```

***

## <a href="http://www.checkmarx.com" target="_blank">Checkmarx</a>
Checkmarx is a commercial static analysis tool.  Since it requires a commercial license, the tasks for Checkmarx are not enabled by default in Codeburner.  If you'd like to use Checkmarx with Codeburner, in addition to a commercial license, you'll need to download the CLI plugin here: <a href="https://www.checkmarx.com/plugins/" target="_blank">https://www.checkmarx.com/plugins/</a>.

Make sure the command 'runCxConsole.sh' from that download is in the $PATH available to Codeburner, and then set the checkmarx_* variables in <a href="https://github.com/groupon/codeburner/blob/master/config/app.yml" target="_blank">config/app.yml</a>:

```yaml

checkmarx_server: my_checkmarx_server
checkmarx_user: my_checkmarx_user
checkmarx_password: my_checkmarx_password
checkmarx_log: my_checkmarx_logfile
```

Also, add '- Checkmarx' to the list of tasks under pipeline_options/tasks_for/<your_language> in <a href="https://github.com/groupon/codeburner/blob/master/config/app.yml" target="_blank">config/app.yml</a>:

```yaml
  tasks_for:
    Ruby:
      - BundleAudit
      - Brakeman
      - Dawnscanner
      - Checkmarx
    JavaScript:
      - RetireJS
      - NodeSecurityProject
      - Checkmarx
    CoffeeScript:
      - RetireJS
      - NodeSecurityProject
    Java:
      - PMD
      - FindSecurityBugs
      - Checkmarx
```

Since Checkmarx does support a few languages not covered by the default open source tools, you can add those languages (as reported by GitHub API) to this list with a '- Checkmarx' item and they should be scanned with Checkmarx as well.


***
