## Environment
The web client is a <a href="http://backbonejs.org/" target="_blank">Backbone.js</a> app written in CoffeeScript.  For layout it uses <a href="https://getbootstrap.com/" target="_blank">Bootstrap</a> with a customized <a href="https://fezvrasta.github.io/bootstrap-material-design/" target="_blank">bootstrap-material-design</a> theme.

All of the development files for the client can be found here: <a href="https://github.com/groupon/codeburner/tree/master/client" target="_blank">https://github.com/groupon/codeburner/tree/master/client</a>.  The rest of this guide assumes you're working out of the <a href="https://github.com/groupon/codeburner/tree/master/client" target="_blank">client/</a> directory.

### Bower
Development on the client side requires <a href="http://bower.io/" target="_blank">Bower</a>.  Assuming you already have <a href="https://nodejs.org/en/" target="_blank">Node.js/npm</a> you can install Bower with:

<pre class="command-line language-bash" data-user="root"><code>npm install -g bower</a></code></pre>

### Bower Install
Once you have <a href="http://bower.io/" target="_blank">Bower</a>, you can use it to install the javascript dependencies:

<pre class="command-line language-bash"><code>bower install</a></code></pre>

### Grunt
The client development environment also requires the <a href="http://gruntjs.com/" target="_blank">Grunt</a> command line tools.  Like bower, you can install them with npm:

<pre class="command-line language-bash" data-user="root"><code>npm install -g grunt-cli</a></code></pre>

### Startup
After grunt is installed you can use it to start the live-reloading development server:

<pre class="command-line language-bash"><code>grunt serve</a></code></pre>

Using default options, you can connect to the client development environment by pointing your browser at <a href="http://localhost:9000" target="_blank">http://localhost:9000/</a>.  Any changes you make in the <a href="https://github.com/groupon/codeburner/tree/master/client" target="_blank">client/</a> directory should be reflected immediately.

## Building
Once you've made changes to the web client that you're happy with and want to publish, you can build the minified javascript/css and pull them in to the <a href="https://github.com/groupon/codeburner/tree/master/public" target="_blank">public/</a> web root with the following capistrano command (run from the root codeburner directory, **not client/**):

<pre class="command-line language-bash"><code>cap frontend:build</a></code></pre>

Once that's done, your changes should appear when visiting base Codeburner URL: <a href="http://localhost:8080/" target="_blank">http://localhost:8080/</a>.

## API Proxy
If you run the rails backend on a port other than port 8080, you'll need to change the API proxy configuration for the client.  You can make these changes in <a href="https://github.com/groupon/codeburner/blob/master/client/Gruntfile.js" target="_blank">client/Gruntfile.js</a>:

```javascript
apiServer: {
  proxies: [{
    context: '/api',
    host: 'localhost',
    port: 8080
  }]
},
```

***
